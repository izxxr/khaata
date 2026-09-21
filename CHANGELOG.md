# Changelog

## v2.2.0

### Additions

- Add support for automatically reconciling account balances
- Add opening balance field at account creation time to automatically
  create first transaction with initial balance
- Add support for importing and exporting accounts and transactions data

### Enhancements

- Transaction modal now spans maximum height to avoid scrolling on
  most devices
- An account is now automatically created and set as default if no account already
  exists when adding transactions

## v2.1.0

### Additions

- Add default accounts to quickly log transactions without selecting accounts explicitly
- Add support for multi-line descriptions for transactions
- Add transactions history page with support for searching and filtering transactions
- Add option to create duplicate transactions from older ones
- Add default category field for counterparties to automatically map counterparty to category
- Add native support for amounts transfers across accounts

### Enhancements

#### Accessibility improvements to transaction logging and management

- Amount field stands out as the default and primary field
- Add natural field focus shifts to seamlessly move to next field
- Allow typing in categories & counterparties dropdowns for searching long lists
- Transaction title is now an optional field to allow quick logging without setting title
- Include option in dropdowns to natively unset categories and counterparties
- Transaction deletion (and the new duplicate) option is now placed in the pop up menu shown on long pressing a transaction

### Bug fixes

- Fix text and fonts theme not applying when using light mode
- Fix dashboard balance including balance of isolated accounts
