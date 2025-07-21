;; Insurance Billing Contract
;; Processes vaccine administration claims and billing

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-CLAIM-NOT-FOUND (err u501))
(define-constant ERR-PROVIDER-NOT-FOUND (err u502))
(define-constant ERR-INVALID-INPUT (err u503))
(define-constant ERR-CLAIM-ALREADY-PROCESSED (err u504))

;; Data Variables
(define-data-var next-claim-id uint u1)
(define-data-var next-provider-id uint u1)

;; Data Maps
(define-map insurance-providers
  { provider-id: uint }
  {
    name: (string-ascii 100),
    contact-info: (string-ascii 200),
    billing-address: (string-ascii 300),
    payment-terms: uint,
    is-active: bool
  }
)

(define-map billing-claims
  { claim-id: uint }
  {
    patient-id: uint,
    provider-id: uint,
    vaccine-type: (string-ascii 50),
    administration-date: uint,
    billing-code: (string-ascii 20),
    claim-amount: uint,
    status: (string-ascii 20),
    submitted-date: uint,
    processed-date: (optional uint),
    payment-amount: (optional uint),
    denial-reason: (optional (string-ascii 200))
  }
)

(define-map patient-insurance
  { patient-id: uint }
  {
    provider-id: uint,
    policy-number: (string-ascii 50),
    group-number: (string-ascii 50),
    effective-date: uint,
    expiration-date: uint,
    copay-amount: uint,
    is-active: bool
  }
)

(define-map billing-codes
  { vaccine-type: (string-ascii 50) }
  {
    cpt-code: (string-ascii 20),
    standard-rate: uint,
    description: (string-ascii 200)
  }
)

(define-map authorized-billers
  { biller: principal }
  { role: (string-ascii 50), is-active: bool }
)

;; Authorization Functions
(define-private (is-authorized-biller (biller principal))
  (or
    (is-eq biller CONTRACT-OWNER)
    (default-to false (get is-active (map-get? authorized-billers { biller: biller })))
  )
)

;; Public Functions

;; Register insurance provider
(define-public (register-insurance-provider
  (name (string-ascii 100))
  (contact-info (string-ascii 200))
  (billing-address (string-ascii 300))
  (payment-terms uint)
)
  (let (
    (provider-id (var-get next-provider-id))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)

    (map-set insurance-providers
      { provider-id: provider-id }
      {
        name: name,
        contact-info: contact-info,
        billing-address: billing-address,
        payment-terms: payment-terms,
        is-active: true
      }
    )

    (var-set next-provider-id (+ provider-id u1))
    (ok provider-id)
  )
)

;; Set patient insurance information
(define-public (set-patient-insurance
  (patient-id uint)
  (provider-id uint)
  (policy-number (string-ascii 50))
  (group-number (string-ascii 50))
  (effective-date uint)
  (expiration-date uint)
  (copay-amount uint)
)
  (let (
    (provider (unwrap! (map-get? insurance-providers { provider-id: provider-id }) ERR-PROVIDER-NOT-FOUND))
  )
    (asserts! (is-authorized-biller tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> patient-id u0) ERR-INVALID-INPUT)
    (asserts! (< effective-date expiration-date) ERR-INVALID-INPUT)

    (map-set patient-insurance
      { patient-id: patient-id }
      {
        provider-id: provider-id,
        policy-number: policy-number,
        group-number: group-number,
        effective-date: effective-date,
        expiration-date: expiration-date,
        copay-amount: copay-amount,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Submit billing claim
(define-public (submit-claim
  (patient-id uint)
  (vaccine-type (string-ascii 50))
  (administration-date uint)
)
  (let (
    (claim-id (var-get next-claim-id))
    (insurance (unwrap! (map-get? patient-insurance { patient-id: patient-id }) ERR-PROVIDER-NOT-FOUND))
    (billing-code-info (map-get? billing-codes { vaccine-type: vaccine-type }))
  )
    (asserts! (is-authorized-biller tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> patient-id u0) ERR-INVALID-INPUT)
    (asserts! (<= administration-date block-height) ERR-INVALID-INPUT)

    (map-set billing-claims
      { claim-id: claim-id }
      {
        patient-id: patient-id,
        provider-id: (get provider-id insurance),
        vaccine-type: vaccine-type,
        administration-date: administration-date,
        billing-code: (default-to "90000" (get cpt-code billing-code-info)),
        claim-amount: (default-to u5000 (get standard-rate billing-code-info)),
        status: "submitted",
        submitted-date: block-height,
        processed-date: none,
        payment-amount: none,
        denial-reason: none
      }
    )

    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)

;; Process claim (approve or deny)
(define-public (process-claim
  (claim-id uint)
  (approved bool)
  (payment-amount (optional uint))
  (denial-reason (optional (string-ascii 200)))
)
  (let (
    (claim (unwrap! (map-get? billing-claims { claim-id: claim-id }) ERR-CLAIM-NOT-FOUND))
  )
    (asserts! (is-authorized-biller tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status claim) "submitted") ERR-CLAIM-ALREADY-PROCESSED)

    (map-set billing-claims
      { claim-id: claim-id }
      (merge claim {
        status: (if approved "approved" "denied"),
        processed-date: (some block-height),
        payment-amount: payment-amount,
        denial-reason: denial-reason
      })
    )
    (ok approved)
  )
)

;; Set billing code rates
(define-public (set-billing-code
  (vaccine-type (string-ascii 50))
  (cpt-code (string-ascii 20))
  (standard-rate uint)
  (description (string-ascii 200))
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> standard-rate u0) ERR-INVALID-INPUT)

    (map-set billing-codes
      { vaccine-type: vaccine-type }
      {
        cpt-code: cpt-code,
        standard-rate: standard-rate,
        description: description
      }
    )
    (ok true)
  )
)

;; Add authorized biller
(define-public (add-authorized-biller (biller principal) (role (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set authorized-billers
      { biller: biller }
      { role: role, is-active: true }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get insurance provider information
(define-read-only (get-insurance-provider (provider-id uint))
  (map-get? insurance-providers { provider-id: provider-id })
)

;; Get patient insurance information
(define-read-only (get-patient-insurance (patient-id uint))
  (map-get? patient-insurance { patient-id: patient-id })
)

;; Get claim information
(define-read-only (get-claim (claim-id uint))
  (map-get? billing-claims { claim-id: claim-id })
)

;; Get billing code information
(define-read-only (get-billing-code (vaccine-type (string-ascii 50)))
  (map-get? billing-codes { vaccine-type: vaccine-type })
)

;; Check if patient has active insurance
(define-read-only (has-active-insurance (patient-id uint))
  (match (map-get? patient-insurance { patient-id: patient-id })
    insurance (and (get is-active insurance)
                  (< block-height (get expiration-date insurance)))
    false
  )
)

;; Calculate patient responsibility
(define-read-only (calculate-patient-responsibility (patient-id uint) (claim-amount uint))
  (match (map-get? patient-insurance { patient-id: patient-id })
    insurance (get copay-amount insurance)
    claim-amount
  )
)
