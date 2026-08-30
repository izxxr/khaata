# Khaata
Simple cross platform finance tracker app.

<br />
<p align="center">
  <image src=".github/collage.jpg" height="500" />
</p>
<br />

**Features:**

- Real-time balance tracking across accounts
- Flexible transactions logging with categories and counterparties
- Isolated accounts for separated transactions e.g. savings
- Insights to view income and spendings across various filters
- Focused around flexibility and customization
- Sleek, user friendly, and modern interface
- ... and [much more](#features-documentation--roadmap)

## Installation
Khaata is written in Flutter and is available as cross platform app.

### Android
For now, pre-built installation binary is only available for Android
and can be downloaded from the following link:

[**Khaata v2.0a1 - Android APK**](https://github.com/izxxr/khaata/releases/download/2.0a1/khaata-v2-0-a1-release-2026-08-24.apk)

### Manual Build for iOS/Windows/Linux/MacOS
For manually building binary for your platform, proceed
with the following steps:

1. Download and install Flutter - refer to [official guide](https://docs.flutter.dev/learn/pathway/quick-install) for this step.

2. Clone this repository via Git:

   ```
   $ git clone https://github.com/izxxr/khaata.git
   ```

3. In the cloned repository, run the flutter build command:

   ```
   $ flutter build <platform> --release
   ```

   Replace `<platform>` with your platform:

   - `apk` for Android
   - `ios` for iOS (requires MacOS with Xcode)
   - `macos` for MacOS
   - `linux` for Linux
   - `windows` for Windows

   The built binary will be located under the `build/` directory
   at the path shown in `build` command's final output.

## Features Documentation & Roadmap
- [x] Accounts and isolated accounts
- [x] Transactions and balance tracking
- [x] Transaction categories
- [x] Counterparties (payeer / payer)
- [x] Finances insights *(under development)*
- [ ] Multi-currencies support
- [ ] Goals for settings and tracking amount targets
- [ ] Transaction types
  - [x] Default transactions
  - [ ] Account transfers 
- [ ] Customization options
  - [x] Themes: dark / light
  - [x] Time format (24h / 12h)
  - [ ] Custom color schemes
  - [ ] Custom currency decimal (for transaction amounts: see [minor units format](https://docs.adyen.com/development-resources/currency-codes), global and account level)