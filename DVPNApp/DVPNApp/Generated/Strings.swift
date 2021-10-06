// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum AccountCreation {
    /// Wallet Address
    internal static let walletAddress = L10n.tr("Localizable", "AccountCreation.WalletAddress")
    /// Please keep record of these phrases exactly, this will never be recovered in any condition.
    internal static let warning = L10n.tr("Localizable", "AccountCreation.Warning")
    internal enum Button {
      internal enum ImportNow {
        /// Import Now
        internal static let action = L10n.tr("Localizable", "AccountCreation.Button.ImportNow.Action")
        /// Already have an account?
        internal static let text = L10n.tr("Localizable", "AccountCreation.Button.ImportNow.Text")
      }
    }
    internal enum Create {
      /// Create Account
      internal static let button = L10n.tr("Localizable", "AccountCreation.Create.Button")
      /// Create a new Account
      internal static let title = L10n.tr("Localizable", "AccountCreation.Create.Title")
    }
    internal enum Error {
      /// Misconfigured wallet. Please, re-check your mnemonic and try again
      internal static let creationFailed = L10n.tr("Localizable", "AccountCreation.Error.CreationFailed")
      /// Please read and accept terms and conditions
      internal static let termsUnchecked = L10n.tr("Localizable", "AccountCreation.Error.TermsUnchecked")
    }
    internal enum Import {
      /// Import Account
      internal static let button = L10n.tr("Localizable", "AccountCreation.Import.Button")
      /// Import security Phrases
      internal static let title = L10n.tr("Localizable", "AccountCreation.Import.Title")
      internal enum Button {
        /// Paste
        internal static let paste = L10n.tr("Localizable", "AccountCreation.Import.Button.Paste")
      }
    }
    internal enum Terms {
      /// terms and conditions
      internal static let button = L10n.tr("Localizable", "AccountCreation.Terms.Button")
      /// I understand and agree to
      internal static let text = L10n.tr("Localizable", "AccountCreation.Terms.Text")
    }
  }

  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "Common.Cancel")
    /// Crypto
    internal static let crypto = L10n.tr("Localizable", "Common.Crypto")
    /// GB
    internal static let gb = L10n.tr("Localizable", "Common.GB")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "Common.Yes")
    internal enum Dvpn {
      /// DVPN
      internal static let title = L10n.tr("Localizable", "Common.DVPN.Title")
    }
  }

  internal enum Error {
    /// Failed to start a session. Please, try again or select another node
    internal static let connectionParsingFailed = L10n.tr("Localizable", "Error.ConnectionParsingFailed")
    /// Selected node is temporary unavailable. Please, try later or select another node
    internal static let unavailableNode = L10n.tr("Localizable", "Error.UnavailableNode")
    internal enum GRPCError {
      /// Request timed-out. No internet connection.
      internal static let rpcTimedOut = L10n.tr("Localizable", "Error.GRPCError.RPCTimedOut")
    }
  }

  internal enum Home {
    internal enum Error {
      /// Misconfigured nodes. Please, try again or select another node
      internal static let invalidURL = L10n.tr("Localizable", "Home.Error.InvalidURL")
      /// Not enough tokens to broadcast - you'll need at least 0.01 DVPN on your account. Please, check your balance and try again later
      internal static let notEnoughTokens = L10n.tr("Localizable", "Home.Error.NotEnoughTokens")
      /// Misconfigured wallet. Please, try again or re-import your mnemonic
      internal static let signatureGenerationFailed = L10n.tr("Localizable", "Home.Error.SignatureGenerationFailed")
    }
    internal enum LocationSelector {
      /// CHANGE
      internal static let change = L10n.tr("Localizable", "Home.LocationSelector.Change")
      /// Select a country
      internal static let select = L10n.tr("Localizable", "Home.LocationSelector.Select")
    }
    internal enum Status {
      internal enum Connection {
        /// Checking balance
        internal static let balanceCheck = L10n.tr("Localizable", "Home.Status.Connection.BalanceCheck")
        /// Connected
        internal static let connected = L10n.tr("Localizable", "Home.Status.Connection.Connected")
        /// Disconnected
        internal static let disconnected = L10n.tr("Localizable", "Home.Status.Connection.Disconnected")
        /// Exchanging keys
        internal static let keysExchange = L10n.tr("Localizable", "Home.Status.Connection.KeysExchange")
        /// Poor or no internet connection
        internal static let lost = L10n.tr("Localizable", "Home.Status.Connection.Lost")
        /// Checking node status
        internal static let nodeStatus = L10n.tr("Localizable", "Home.Status.Connection.NodeStatus")
        /// Waiting for confirmation
        internal static let sessionBroadcast = L10n.tr("Localizable", "Home.Status.Connection.SessionBroadcast")
        /// Checking last session status
        internal static let sessionStatus = L10n.tr("Localizable", "Home.Status.Connection.SessionStatus")
        /// Fetching the subscription
        internal static let subscriptionStatus = L10n.tr("Localizable", "Home.Status.Connection.SubscriptionStatus")
        /// Preparing iOS VPN tunnel
        internal static let tunnelUpdating = L10n.tr("Localizable", "Home.Status.Connection.TunnelUpdating")
      }
    }
    internal enum Subscription {
      internal enum Amount {
        /// remaining of %d GB
        internal static func description(_ p1: Int) -> String {
          return L10n.tr("Localizable", "Home.Subscription.Amount.Description", p1)
        }
      }
    }
  }

  internal enum LocationSelection {
    internal enum Extra {
      /// Built by
      internal static let build = L10n.tr("Localizable", "LocationSelection.Extra.Build")
      /// Sentinel P2P bandwidth market place
      internal static let subtitle = L10n.tr("Localizable", "LocationSelection.Extra.Subtitle")
      /// The blockchain bandwidth Infrastructure for web 3.0
      internal static let text = L10n.tr("Localizable", "LocationSelection.Extra.Text")
      /// Extra
      internal static let title = L10n.tr("Localizable", "LocationSelection.Extra.Title")
      internal enum Button {
        /// Learn more
        internal static let more = L10n.tr("Localizable", "LocationSelection.Extra.Button.More")
      }
    }
    internal enum Node {
      /// Nodes
      internal static let title = L10n.tr("Localizable", "LocationSelection.Node.Title")
      internal enum All {
        /// No available nodes found, please try later
        internal static let notFound = L10n.tr("Localizable", "LocationSelection.Node.All.NotFound")
        /// All nodes
        internal static let title = L10n.tr("Localizable", "LocationSelection.Node.All.Title")
      }
      internal enum Details {
        /// Latency
        internal static let latency = L10n.tr("Localizable", "LocationSelection.Node.Details.Latency")
        /// Peers
        internal static let peers = L10n.tr("Localizable", "LocationSelection.Node.Details.Peers")
        /// Price
        internal static let price = L10n.tr("Localizable", "LocationSelection.Node.Details.Price")
      }
      internal enum Subscribed {
        /// You are not subscribed to any nodes
        internal static let notFound = L10n.tr("Localizable", "LocationSelection.Node.Subscribed.NotFound")
        /// Subscribed
        internal static let title = L10n.tr("Localizable", "LocationSelection.Node.Subscribed.Title")
      }
    }
  }

  internal enum Onboarding {
    internal enum Button {
      /// Next
      internal static let next = L10n.tr("Localizable", "Onboarding.Button.Next")
      /// Skip
      internal static let skip = L10n.tr("Localizable", "Onboarding.Button.Skip")
      /// Get started
      internal static let start = L10n.tr("Localizable", "Onboarding.Button.Start")
      internal enum ImportNow {
        /// Import Now
        internal static let action = L10n.tr("Localizable", "Onboarding.Button.ImportNow.Action")
        /// Already have an account?
        internal static let text = L10n.tr("Localizable", "Onboarding.Button.ImportNow.Text")
      }
    }
    internal enum Description {
      /// Sentinel is not just a VPN, it's a 'decentralized' open-source provable VPN or a 'dVPN'.
      internal static let _1 = L10n.tr("Localizable", "Onboarding.Description.1")
      /// The Sentinel dVPN can prove that your connection is being end-to-end encrypted with no exceptions
      internal static let _2 = L10n.tr("Localizable", "Onboarding.Description.2")
      /// The Sentinel dVPN doesn't control and own the exit-servers that you trust to safely and securely browse the internet.
      internal static let _3 = L10n.tr("Localizable", "Onboarding.Description.3")
    }
    internal enum Title {
      /// Join VPN Quickly
      internal static let _1 = L10n.tr("Localizable", "Onboarding.Title.1")
      /// Secure Safely
      internal static let _2 = L10n.tr("Localizable", "Onboarding.Title.2")
      /// Enjoy Simply
      internal static let _3 = L10n.tr("Localizable", "Onboarding.Title.3")
    }
  }

  internal enum Plans {
    /// Buy
    internal static let buy = L10n.tr("Localizable", "Plans.Buy")
    internal enum AddTokens {
      /// Top-up your wallet?
      internal static let subtitle = L10n.tr("Localizable", "Plans.AddTokens.Subtitle")
      /// Not enough tokens to subcribe
      internal static let title = L10n.tr("Localizable", "Plans.AddTokens.Title")
    }
    internal enum Amount {
      /// Unlimited
      internal static let title = L10n.tr("Localizable", "Plans.Amount.Title")
    }
    internal enum Error {
      internal enum Payment {
        /// Your transaction was unsuccessful. Please try again.
        internal static let failed = L10n.tr("Localizable", "Plans.Error.Payment.Failed")
      }
    }
    internal enum Subscribe {
      /// Subscribe to %@?
      internal static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "Plans.Subscribe.Title", String(describing: p1))
      }
    }
  }

  internal enum SecurityService {
    internal enum Error {
      /// Empty mnemonic. Please, enter valid ones and try again
      internal static let emptyInput = L10n.tr("Localizable", "SecurityService.Error.EmptyInput")
      /// Invalid mnemonic. Please, enter valid one and try again
      internal static let invalidInput = L10n.tr("Localizable", "SecurityService.Error.InvalidInput")
    }
  }

  internal enum SentinelService {
    internal enum Error {
      /// Couldn't process the broadcast. Please, check your balance and try again later
      internal static let broadcastFailed = L10n.tr("Localizable", "SentinelService.Error.BroadcastFailed")
    }
  }

  internal enum Settings {
    /// Scan QR code to receive
    internal static let qr = L10n.tr("Localizable", "Settings.QR")
    internal enum Balance {
      /// Your have: 
      internal static let title = L10n.tr("Localizable", "Settings.Balance.Title")
      internal enum Loading {
        /// - DVPN
        internal static let title = L10n.tr("Localizable", "Settings.Balance.Loading.Title")
      }
    }
    internal enum Copyright {
      /// Copyright 2021
      internal static let subtitle = L10n.tr("Localizable", "Settings.Copyright.Subtitle")
      /// Sentinel V 1.0
      internal static let title = L10n.tr("Localizable", "Settings.Copyright.Title")
    }
    internal enum Dns {
      /// Cloudflare
      internal static let cloudflare = L10n.tr("Localizable", "Settings.DNS.Cloudflare")
      /// Freenom
      internal static let freenom = L10n.tr("Localizable", "Settings.DNS.Freenom")
      /// Google
      internal static let google = L10n.tr("Localizable", "Settings.DNS.Google")
      /// Handshake
      internal static let handshake = L10n.tr("Localizable", "Settings.DNS.Handshake")
      /// Default DNS Server
      internal static let title = L10n.tr("Localizable", "Settings.DNS.Title")
    }
    internal enum Wallet {
      /// Balance
      internal static let title = L10n.tr("Localizable", "Settings.Wallet.Title")
    }
  }

  internal enum WalletService {
    internal enum Error {
      /// Self-sending is not supported
      internal static let accountMatchesDestination = L10n.tr("Localizable", "WalletService.Error.AccountMatchesDestination")
      /// Misconfigured wallet: failed to fetch authorization. Please, try again or re-import your mnemonic
      internal static let missingAuthorization = L10n.tr("Localizable", "WalletService.Error.MissingAuthorization")
      /// Misconfigured wallet: missing mnemonic. Please, try again or re-import your mnemonic
      internal static let missingMnemonics = L10n.tr("Localizable", "WalletService.Error.MissingMnemonics")
      /// Misconfigured wallet: mnemonic mismatch. Please, try again or re-import your mnemonic
      internal static let mnemonicsDoNotMatch = L10n.tr("Localizable", "WalletService.Error.MnemonicsDoNotMatch")
      /// Not enough tokens to broadcast. Please, check your balance and try again later
      internal static let notEnoughTokens = L10n.tr("Localizable", "WalletService.Error.NotEnoughTokens")
      /// Couldn't save wallet. Please, try again.
      internal static let savingError = L10n.tr("Localizable", "WalletService.Error.SavingError")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
