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
For now, pre-built installation binary is only available for Android. Download
the latest APK for your device from the [releases page](https://github.com/izxxr/khaata/releases)

> **Don't know which one to download?** Download the APK ending with `*-arm64-v8a.apk` as it is compatible with most modern Android devices.
>
> If the installation process shows incompatibility message, download the other APK ending with `*-arm64-v7a.apk`

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
- [x] Income/spending insights and transactions search
- [ ] Multi-currencies support
- [ ] Goals for settings and tracking amount targets
- [x] Transaction types
  - [x] Default transactions
  - [x] Account transfers 
  - [x] Automatic balance reconcilation
- [ ] Customization options
  - [x] Themes: dark / light
  - [x] Time format (24h / 12h)
  - [ ] Custom color schemes
  - [ ] Custom currency decimal (for transaction amounts: see [minor units format](https://docs.adyen.com/development-resources/currency-codes), global and account level)

Specific features that are planned for near future can be viewed in the [project kanban](https://github.com/users/izxxr/projects/10/views/1).
