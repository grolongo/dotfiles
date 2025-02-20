# Restriction: use "Set-ExecutionPolicy Bypass" as admin to allow this script to run

#Requires -RunAsAdministrator

### Common functions

function Ask-Question {
    param(
        [Parameter(Mandatory=$true)]
        [string]$question
    )
    do {
        $response = Read-Host "$question [y/n]"
        $response = $response.ToLower()
        switch ($response) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Host "Please enter 'y' or 'n'"
            }
        }
    } while ($response -ne 'y' -and $response -ne 'n')
}

function Write-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]$message
    )
    Write-Host -ForegroundColor 'yellow' $message
}

### Group Policies

function apply_gpo {

    if (-not (Get-Module PolicyFileEditor -ListAvailable)) {
        Install-Module -Name PolicyFileEditor -Force
    }

    $MachineDir = "$env:windir\System32\GroupPolicy\Machine\Registry.pol"

    $RegPath01 = 'Software\Policies\Microsoft\Windows\Personalization'
    $RegPath02 = 'Software\Policies\Microsoft\InputPersonalization'
    $RegPath03 = 'Software\Policies\Microsoft\MUI\Settings'
    $RegPath04 = 'Software\Policies\Microsoft\Control Panel\International'
    $RegPath06 = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $RegPath07 = 'Software\Policies\Microsoft\Windows\System'
    $RegPath08 = 'Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
    $RegPath09 = 'Software\Policies\Microsoft\WindowsFirewall\StandardProfile'
    $RegPath10 = 'Software\Policies\Microsoft\Windows\Explorer'
    $RegPath11 = 'Software\Policies\Microsoft\SQMClient\Windows'
    $RegPath12 = 'Software\Policies\Microsoft\PCHealth\ErrorReporting'
    $RegPath13 = 'Software\Policies\Microsoft\Windows\Windows Error Reporting'
    $RegPath14 = 'Software\Policies\Microsoft\Messenger\Client'
    $RegPath15 = 'Software\Policies\Microsoft\Windows NT\SystemRestore'
    $RegPath16 = 'Software\Policies\Microsoft\Windows\AdvertisingInfo'
    $RegPath17 = 'Software\Policies\Microsoft\Windows\AppPrivacy'
    $RegPath18 = 'Software\Microsoft\Windows\CurrentVersion\Policies\System'
    $RegPath19 = 'Software\Policies\Microsoft\Windows\AppCompat'
    $RegPath20 = 'Software\Policies\Microsoft\Windows\Windows Chat'
    $RegPath21 = 'Software\Policies\Microsoft\Windows\CloudContent'
    $RegPath22 = 'Software\Policies\Microsoft\Windows\PreviewBuilds'
    $RegPath23 = 'Software\Policies\Microsoft\Windows\DataCollection'
    $RegPath24 = 'Software\Policies\Microsoft\Windows\DWM'
    $RegPath25 = 'Software\Policies\Microsoft\Windows\EdgeUI'
    $RegPath26 = 'Software\Policies\Microsoft\Windows\LocationAndSensors'
    $RegPath27 = 'Software\Policies\Microsoft\Windows\Maps'
    $RegPath28 = 'Software\Policies\Microsoft\MicrosoftAccount'
    $RegPath29 = 'Software\Policies\Microsoft\Windows Defender'
    $RegPath30 = 'Software\Policies\Microsoft\MicrosoftEdge\ServiceUI'
    $RegPath31 = 'Software\Policies\Microsoft\MicrosoftEdge\Addons'
    $RegPath32 = 'Software\Policies\Microsoft\MicrosoftEdge\BooksLibrary'
    $RegPath33 = 'Software\Policies\Microsoft\MicrosoftEdge\Main'
    $RegPath34 = 'Software\Policies\Microsoft\MicrosoftEdge\TabPreloader'
    $RegPath35 = 'Software\Policies\Microsoft\MicrosoftEdge\Internet Settings'
    $RegPath36 = 'Software\Policies\Microsoft\MicrosoftEdge\SearchScopes'
    $RegPath38 = 'Software\Microsoft\OneDrive'
    $RegPath39 = 'Software\Policies\Microsoft\Windows\OneDrive'
    $RegPath40 = 'Software\Policies\Microsoft\Windows NT\Terminal Services'
    $RegPath41 = 'Software\Policies\Microsoft\Windows\Windows Search'
    $RegPath42 = 'Software\Policies\Microsoft\WindowsStore'
    $RegPath43 = 'Software\Policies\Microsoft\Dsh'
    $RegPath44 = 'Software\Policies\Microsoft\Windows\GameDVR'
    $RegPath45 = 'Software\Policies\Microsoft\PassportForWork'
    $RegPath46 = 'Software\Policies\Microsoft\WindowsInkWorkspace'
    $RegPath47 = 'Software\Policies\Microsoft\WindowsMediaPlayer'
    $RegPath48 = 'Software\Policies\Microsoft\Messenger\Client'
    $RegPath49 = 'Software\Policies\Microsoft\Windows\WinRM\Service\WinRS'

    # Computer Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath01 -ValueName 'AnimateLockScreenBackground'                  -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath01 -ValueName 'NoChangingStartMenuBackground'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath01 -ValueName 'NoLockScreenCamera'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath01 -ValueName 'NoLockScreenSlideshow'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath02 -ValueName 'AllowInputPersonalization'                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath02 -ValueName 'PreferredUILanguages'                         -Data 'en-US' -Type 'String'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath03 -ValueName 'MachineUILock'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath04 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath02 -ValueName 'RestrictImplicitTextCollection'               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath02 -ValueName 'RestrictImplicitInkCollection'                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel > User Accounts
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'UseDefaultTile'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Control Panel
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'AllowOnlineTips'                              -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Fonts
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath07 -ValueName 'EnableFontProviders'                          -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Domain Profile
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath08 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Standard Profile
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath09 -ValueName 'EnableFirewall'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'ForceStartSize'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'HideRecentlyAddedApps'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'HideRecommendedPersonalizedSites'             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'HideRecommendedSection'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'ShowOrHideMostUsedApps'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoRecentDocsHistory'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'HideTaskViewButton'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'TaskbarNoPinnedList'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoStartMenuMFUprogramsList'                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath11 -ValueName 'CEIPEnable'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath12 -ValueName 'DoReport'                                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath13 -ValueName 'Disabled'                                     -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoInternetOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'NoUseStoreOpenWith'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoWebServices'                                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoOnlinePrintsWizard'                         -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoPublishingWizard'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath14 -ValueName 'CEIP'                                         -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > Logon
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath07 -ValueName 'BlockUserFromShowingAccountDetailsOnSignin'   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath07 -ValueName 'DisableLockScreenAppNotifications'            -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > System Restore
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath15 -ValueName 'DisableSR'                                    -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath15 -ValueName 'DisableConfig'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > System > User Profiles
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath16 -ValueName 'DisabledByGroupPolicy'                        -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App Privacy
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessAccountInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessGazeInput'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessCallHistory'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessContacts'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsGetDiagnosticInfo'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessEmail'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessLocation'                        -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessMessaging'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessMotion'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessCamera'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessMicrophone'                      -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessBackgroundSpatialPerception'     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsActivateWithVoice'                     -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsActivateWithVoiceAboveLock'            -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessRadios'                          -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessPhone'                           -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsRunInBackground'                       -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath17 -ValueName 'LetAppsAccessGraphicsCaptureProgrammatic'     -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > App runtime
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath18 -ValueName 'MSAOptional'                                  -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Application Compatibility
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath19 -ValueName 'AITEnable'                                    -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath19 -ValueName 'DisableInventory'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath19 -ValueName 'DisableUAR'                                   -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoDriveTypeAutoRun'                           -Data '255'   -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'NoAutoplayfornonVolume'                       -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath06 -ValueName 'NoAutorun'                                    -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Chat
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath20 -ValueName 'ChatIcon'                                     -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath21 -ValueName 'DisableSoftLanding'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath21 -ValueName 'DisableWindowsConsumerFeatures'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath22 -ValueName 'AllowBuildPreview'                            -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath23 -ValueName 'AllowTelemetry'                               -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath23 -ValueName 'DisableTelemetryOptInSettingsUx'              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath23 -ValueName 'LimitDiagnosticLogCollection'                 -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath23 -ValueName 'LimitDumpCollection'                          -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath23 -ValueName 'DoNotShowFeedbackNotifications'               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath24 -ValueName 'DisableAccentGradient'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath24 -ValueName 'DisallowAnimations'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath25 -ValueName 'AllowEdgeSwipe'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath25 -ValueName 'DisableHelpSticker'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'ExplorerRibbonStartsMinimized'                -Data '2'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath10 -ValueName 'DisableGraphRecentItems'                      -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath26 -ValueName 'DisableLocation'                              -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath26 -ValueName 'DisableLocationScripting'                     -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Maps
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath27 -ValueName 'AutoDownloadAndUpdateMapData'                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath27 -ValueName 'AllowUntriggeredNetworkTrafficOnSettingsPage' -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft accounts
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath28 -ValueName 'DisableUserAuth'                              -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Defender Antivirus
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath29 -ValueName 'PUAProtection'                                -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath30 -ValueName 'ShowOneBox'                                   -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath31 -ValueName 'FlashPlayerEnabled'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath32 -ValueName 'AllowConfigurationUpdateForBooksLibrary'      -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'AllowFullScreenMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'AllowPrelaunch'                               -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath34 -ValueName 'AllowTabPreloading'                           -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath30 -ValueName 'AllowWebContentOnNewTabPage'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'Use FormSuggest'                              -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'ConfigureFavoritesBar'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath35 -ValueName 'ConfigureHomeButton'                          -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'AllowPopups'                                  -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath36 -ValueName 'ShowSearchSuggestionsGlobal'                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'       -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'PreventLiveTileDataCollection'                -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath33 -ValueName 'PreventFirstRunPage'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > OneDrive
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath38 -ValueName 'PreventNetworkTrafficPreUserSignIn'           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath39 -ValueName 'DisableFileSyncNGSC'                          -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath40 -ValueName 'fDenyTSConnections'                           -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'AllowCloudSearch'                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'AllowCortanaAboveLock'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'AllowCortana'                                 -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'SearchOnTaskbarMode'                          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'DisableWebSearch'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'ConnectedSearchUseWeb'                        -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'ConnectedSearchPrivacy'                       -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath41 -ValueName 'ConnectedSearchSafeSearch'                    -Data '3'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath42 -ValueName 'DisableOSUpgrade'                             -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath42 -ValueName 'AutoDownload'                                 -Data '2'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Widgets
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath43 -ValueName 'AllowNewsAndInterests'                        -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath43 -ValueName 'DisableWidgetsOnLockScreen'                   -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Game Recording and Broadcasting
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath44 -ValueName 'AllowGameDVR'                                 -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath45 -ValueName 'Enabled'                                      -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Ink Workspace
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath46 -ValueName 'AllowWindowsInkWorkspace'                     -Data '0'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Media Player
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath47 -ValueName 'QuickLaunchShortcut'                          -Data 'no'    -Type 'String'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath48 -ValueName 'PreventRun'                                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath48 -ValueName 'PreventAutoRun'                               -Data '1'     -Type 'DWord'
    # Computer Configuration > Administrative Templates > Windows Components > Windows Remote Shell
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath49 -ValueName 'AllowRemoteShellAccess'                       -Data '0'     -Type 'DWord'

    # ===========
    # User Config
    # ===========

    $UserDir = "$env:windir\System32\GroupPolicy\User\Registry.pol"

    $RegPath50 = 'Software\Policies\Microsoft\Windows\Control Panel\Desktop'
    $RegPath51 = 'Software\Policies\Microsoft\InputPersonalization'
    $RegPath52 = 'Software\Policies\Microsoft\Control Panel\Desktop'
    $RegPath53 = 'Software\Policies\Microsoft\Control Panel\International'
    $RegPath54 = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $RegPath55 = 'Software\Policies\Microsoft\Windows\Explorer'
    $RegPath56 = 'Software\Policies\Microsoft\Assistance\Client\1.0'
    $RegPath57 = 'Software\Policies\Microsoft\Messenger\Client'
    $RegPath58 = 'Software\Policies\Microsoft\Windows\CloudContent'
    $RegPath59 = 'Software\Policies\Microsoft\Windows\DataCollection'
    $RegPath60 = 'Software\Policies\Microsoft\Windows\DWM'
    $RegPath61 = 'Software\Policies\Microsoft\Windows\EdgeUI'
    $RegPath62 = 'Software\Policies\Microsoft\ime\imejp'
    $RegPath63 = 'Software\Policies\Microsoft\ime\shared'
    $RegPath64 = 'Software\Policies\Microsoft\Windows\LocationAndSensors'
    $RegPath65 = 'Software\Policies\Microsoft\MicrosoftEdge\ServiceUI'
    $RegPath66 = 'Software\Policies\Microsoft\MicrosoftEdge\Addons'
    $RegPath67 = 'Software\Policies\Microsoft\MicrosoftEdge\BooksLibrary'
    $RegPath68 = 'Software\Policies\Microsoft\MicrosoftEdge\Main'
    $RegPath69 = 'Software\Policies\Microsoft\MicrosoftEdge\TabPreloader'
    $RegPath70 = 'Software\Policies\Microsoft\MicrosoftEdge\Internet Settings'
    $RegPath71 = 'Software\Policies\Microsoft\MicrosoftEdge\SearchScopes'
    $RegPath72 = 'Software\Policies\Microsoft\WindowsStore'
    $RegPath73 = 'Software\Policies\Microsoft\Windows\WindowsCopilot'
    $RegPath74 = 'Software\Policies\Microsoft\Windows\Windows Error Reporting'
    $RegPath75 = 'Software\Policies\Microsoft\PassportForWork'
    $RegPath76 = 'Software\Policies\Microsoft\Messenger\Client'

    # User Configuration > Administrative Templates > Control Panel > Personalization
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath50 -ValueName 'ScreenSaveActive'                                -Data '0'        -Type 'String'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath52 -ValueName 'PreferredUILanguages'                            -Data 'en-US'    -Type 'String'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath52 -ValueName 'MultiUILanguageID'                               -Data '00000409' -Type 'String'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath53 -ValueName 'RestrictLanguagePacksAndFeaturesInstall'         -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath53 -ValueName 'TurnOffAutocorrectMisspelledWords'               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath53 -ValueName 'TurnOffHighlightMisspelledWords'                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath53 -ValueName 'TurnOffOfferTextPredictions'                     -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Control Panel > Regional and Language Options > Handwriting personalization
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath51 -ValueName 'RestrictImplicitTextCollection'                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath51 -ValueName 'RestrictImplicitInkCollection'                   -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Desktop
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoInternetIcon'                                  -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Start Menu and Taskbar
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'ClearRecentDocsOnExit'                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'ClearRecentProgForNewUserInStartMenu'            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoRecentDocsHistory'                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'ForceStartSize'                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'HideTaskViewButton'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'LockTaskbar'                                     -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoTaskGrouping'                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'HideRecentlyAddedApps'                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoStartMenuMFUprogramsList'                      -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'HideRecommendedPersonalizedSites'                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'TaskbarNoPinnedList'                             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoStartMenuPinnedList'                           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoRecentDocsMenu'                                -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'HideRecommendedSection'                          -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'HideSCAMeetNow'                                  -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'HidePeopleBar'                                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'ShowOrHideMostUsedApps'                          -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'ShowWindowsStoreAppsOnTaskbar'                   -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoAutoTrayNotify'                                -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > System > Internet Communication Management > Internet Communication settings
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'NoUseStoreOpenWith'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath56 -ValueName 'NoImplicitFeedback'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoWebServices'                                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoInternetOpenWith'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoOnlinePrintsWizard'                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoPublishingWizard'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath57 -ValueName 'CEIP'                                            -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath56 -ValueName 'NoOnlineAssist'                                  -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > AutoPlay Policies
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoAutorun'                                       -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoDriveTypeAutoRun'                              -Data '255'      -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'NoAutoplayfornonVolume'                          -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Cloud Content
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'ConfigureWindowsSpotlight'                       -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableThirdPartySuggestions'                    -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableTailoredExperiencesWithDiagnosticData'    -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableWindowsSpotlightFeatures'                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableSpotlightCollectionOnDesktop'             -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableWindowsSpotlightWindowsWelcomeExperience' -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableWindowsSpotlightOnActionCenter'           -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath58 -ValueName 'DisableWindowsSpotlightOnSettings'               -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath59 -ValueName 'AllowTelemetry'                                  -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Desktop Window Manager
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath60 -ValueName 'DisallowAnimations'                              -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Edge UI
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath61 -ValueName 'AllowEdgeSwipe'                                  -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath61 -ValueName 'DisableHelpSticker'                              -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath61 -ValueName 'DisableRecentApps'                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath61 -ValueName 'DisableCharms'                                   -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath61 -ValueName 'TurnOffBackstack'                                -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > File Explorer
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'MaxRecentDocs'                                   -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'NoSearchInternetTryHarderButton'                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'NoChangeAnimation'                               -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'ExplorerRibbonStartsMinimized'                   -Data '2'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath54 -ValueName 'TurnOffSPIAnimations'                            -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'DisableSearchBoxSuggestions'                     -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > IME
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath62 -ValueName 'UseHistorybasedPredictiveInput'                  -Data '0'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath63 -ValueName 'SearchPlugin'                                    -Data '0'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Location and Sensors
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath64 -ValueName 'DisableLocation'                                 -Data '1'        -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath64 -ValueName 'DisableLocationScripting'                        -Data '1'        -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Microsoft Edge
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath65 -ValueName 'ShowOneBox'                                      -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath66 -ValueName 'FlashPlayerEnabled'                              -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath67 -ValueName 'AllowConfigurationUpdateForBooksLibrary'         -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'AllowFullScreenMode'                             -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'AllowPrelaunch'                                  -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath69 -ValueName 'AllowTabPreloading'                              -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath65 -ValueName 'AllowWebContentOnNewTabPage'                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'Use FormSuggest'                                 -Data 'no'    -Type 'String'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'ConfigureFavoritesBar'                           -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath70 -ValueName 'ConfigureHomeButton'                             -Data '3'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'AllowPopups'                                     -Data 'yes'   -Type 'String'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath71 -ValueName 'ShowSearchSuggestionsGlobal'                     -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'SyncFavoritesBetweenIEAndMicrosoftEdge'          -Data '0'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'PreventLiveTileDataCollection'                   -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath68 -ValueName 'PreventFirstRunPage'                             -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Search
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath55 -ValueName 'DisableSearchHistory'                            -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Store
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath72 -ValueName 'DisableOSUpgrade'                                -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Copilot
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath73 -ValueName 'TurnOffWindowsCopilot'                           -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Error Reporting
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath74 -ValueName 'Disabled'                                        -Data '1'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Hello for Business
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath75 -ValueName 'Enabled'                                         -Data '0'     -Type 'DWord'
    # User Configuration > Administrative Templates > Windows Components > Windows Messenger
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath76 -ValueName 'PreventRun'                                      -Data '1'     -Type 'DWord'
    Set-PolicyFileEntry -Path $UserDir -Key $RegPath76 -ValueName 'PreventAutoRun'                                  -Data '1'     -Type 'DWord'

    gpupdate /force
}

### UI/UX Preferences

function set_uipreferences {
    $explorer = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
    $exploreradvanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

    # dark mode
    Write-Message 'Setting Windows dark mode...'
    Set-ItemProperty -Path $personalize -Name AppsUseLightTheme -Value 0
    Set-ItemProperty -Path $personalize -Name SystemUsesLightTheme -Value 0

    # hidden files
    Write-Message 'Show hidden files...'
    Set-ItemProperty -Path $exploreradvanced -Name 'Hidden' -Value 1

    # file extentions
    Write-Message 'Show file extentions...'
    Set-ItemProperty -Path $exploreradvanced -Name 'HideFileExt' -Value 0

    # Bing search
    Write-Message 'Disabling Bing search...'
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name 'BingSearchEnabled' -Value 0

    # show icons notification area (always show = 0, not showing = 1)
    Write-Message 'Showing all tray icons...'
    Set-ItemProperty -Path $explorer -Name 'EnableAutoTray' -Value 0

    # taskbar alignment
    Write-Message 'Align taskbar to the left...'
    Set-ItemProperty -Path $exploreradvanced -Name "TaskbarAl" -Value 0

    # taskbar size (small = 1, large = 0)
    Write-Message 'Setting taskbar height size to small...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSmallIcons' -Value 1

    # taskbar combine (always = 0, when full = 1, never = 2)
    Write-Message 'Setting taskbar combine when full mode...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarGlomLevel' -Value 1

    # lock taskbar (lock = 0, unlock = 1)
    Write-Message 'Locking the taskbar...'
    Set-ItemProperty -Path $exploreradvanced -Name 'TaskbarSizeMove' -Value 0

    # disable recent files, folders and cloud files (hidden = 0, show = 1)
    Write-Message 'Disabling recent files and cloud folders...'
    Set-ItemProperty -Path $exploreradvanced -Name 'CloudFilesOnDemand' -Value 0
    Set-ItemProperty -Path $exploreradvanced -Name 'Start_TrackDocs' -Value 0
    Set-ItemProperty -Path $explorer -Name 'ShowFrequent' -Value 0

    # Start menu layout
    Write-Message 'Setting up the Start menu...'
    Set-ItemProperty -Path $exploreradvanced -Name 'Start_Layout' -Value 1 # (1 = More pins, 2 = More recommendations, 3 = Default)

    # disable transparency (1 = enabled, 0 = disabled)
    Write-Message 'Disabling transparency effects...'
    Set-ItemProperty -Path $personalize -Name 'EnableTransparency' -Value 0

    # sticky keys
    Write-Message 'Disabling sticky keys...'
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name Flags -Value 58

    # Snap windows
    Write-Message 'Disabling snapping of windows on startup...'
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WindowArrangementActive -Value 0
    Write-Message 'Disabling snap assist suggestion on startup...'
    Set-ItemProperty -Path $exploreradvanced -Name WindowArrangementActive -Value 0
    Write-Message 'Disabling snap assist flyout on startup...'
    Set-ItemProperty -Path $exploreradvanced -Name EnableSnapAssistFlyout -Value 0

    # Recall
    Write-Message "Disabling Recall..."
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsAI" -Name 'DisableAIDataAnalysis' -Value 1
    DISM /Online /Disable-Feature /FeatureName:Recall

    # screenshot folder
    Write-Message 'Setting the screenshot folder to Desktop...'
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name '{B7BEDE81-DF94-4682-A7D8-57A52620B86F}' -Value "$env:USERPROFILE\Desktop"

    if (Ask-Question 'Set timezone/currency/timeformat to fr-FR?') {
        Set-TimeZone -Name 'Romance Standard Time'
        Set-Culture fr-FR
    }

    Stop-Process -Name explorer -Force
    Write-Message 'Might need to relog for changes to take effect.'
}

### No sound

function set_nosound {
    Write-Message 'Switching Sound Scheme to no sounds...'
    New-ItemProperty -Path "HKCU:\AppEvents\Schemes" -Name '(Default)' -Value '.None' -Force | Out-Null
    Get-ChildItem -Path "HKCU:\AppEvents\Schemes\Apps" -Recurse | Where-Object { $_.PSChildName -eq '.Current' } | Set-ItemProperty -Name '(Default)' -Value ''

    Write-Message 'Turning Windows Startup sound off...'
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name 'DisableStartupSound' -Value 1 -Type DWord -Force
}

### BitLocker

function enable_bitlocker {
    $MachineDir = "$env:windir\system32\GroupPolicy\Machine\Registry.pol"
    $RegPath = 'Software\Policies\Microsoft\FVE'
    $RegType = 'DWord'

    if (-not (Get-Module PolicyFileEditor -ListAvailable)) {
        Install-Module -Name PolicyFileEditor -Force
    }

    # OS drive
    Write-Message 'Enforce full disk encryption for OS drive instead of used space...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSEncryptionType'         -Data '1' -Type $RegType
    Write-Message 'Require additional authentication at startup...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseAdvancedStartup'       -Data '1' -Type $RegType
    Write-Message 'Do not allow BitLocker without TPM...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'EnableBDEWithNoTPM'       -Data '0' -Type $RegType
    Write-Message 'Do not allow TPM solely...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseTPM'                   -Data '0' -Type $RegType
    Write-Message 'Do not allow external startup key...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseTPMKey'                -Data '0' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseTPMKeyPIN'             -Data '0' -Type $RegType
    Write-Message 'Only require startup PIN with TPM...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseTPMPIN'                -Data '1' -Type $RegType
    Write-Message 'Allow enhanced PINs...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'UseEnhancedPin'           -Data '1' -Type $RegType
    Write-Message 'Enabling only password recovery for the OS drive...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSRecovery'               -Data '1' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSManageDRA'              -Data '0' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSRecoveryKey'            -Data '0' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSRecoveryPassword'       -Data '1' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'OSActiveDirectoryBackup'  -Data '0' -Type $RegType

    # Fixed drives
    Write-Message 'Enforce full disk encryption for fixed drives instead of used space...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'FDVEncryptionType'        -Data '1' -Type $RegType
    Write-Message 'Setting recovery options for fixed drives...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'FDVRecovery'              -Data '1' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'FDVManageDRA'             -Data '0' -Type $RegType
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'FDVActiveDirectoryBackup' -Data '0' -Type $RegType
    Write-Message 'Disabling smart cards option...'
    Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName 'FDVAllowUserCert'         -Data '0' -Type $RegType

    Start-Sleep -Seconds 3

    gpupdate /force

    Start-Sleep -Seconds 3

    if (Ask-Question 'Encrypt C: drive?') {
        manage-bde -protectors -add c: -TPMAndPIN
        Start-Sleep -Seconds 3
        manage-bde -on c: -RecoveryPassword
    }

    $Drives = (BitlockerVolume | Where-Object {$_.AutoUnlockEnabled -eq $false}).MountPoint

    if ($Drives) {
        foreach ($Drive in $Drives) {
            if (Ask-Question "Automatically unlock $Drive at boot?") {
                manage-bde -unlock "$Drive" -password
                Start-Sleep -Seconds 10
                manage-bde -autounlock -enable "$Drive"
            }
        }
    }
}

### Firewall

function set_firewall {
    if (Ask-Question 'Block incoming connections and allow outgoing?') {
        Set-NetConnectionProfile -NetworkCategory Private
        netsh advfirewall set allprofiles state on
        netsh advfirewall set domainprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
        netsh advfirewall set privateprofile firewallpolicy blockinboundalways,allowoutbound
    }
}

### SSH

function set_ssh {
    Set-Service ssh-agent -StartupType Automatic
}

### Power Settings

function power_settings {
    Write-Message 'Turning off all power saving mode when on AC power...'
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -disk-timeout-ac 0
    powercfg -change -hibernate-timeout-ac 0

    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem

    if ($computerSystem.PCSystemType -eq 2) {
        Write-Message 'Running on a laptop, keeping hibernate on...'
    } else {
        Write-Message 'Turning hibernate off...'
        powercfg.exe /HIBERNATE off
    }
}

### Environment Variables

function install_envar {
    $cloudpath = Read-Host 'Enter cloud folder path (ex: C:\Users\Bob\Seafile)'
    while (!(Test-path $cloudpath)) {
        $cloudpath = Read-Host 'Invalid path, please re-enter'
    }
    [Environment]::SetEnvironmentVariable('DOTFILES_DIR', "$cloudpath" + "\Dotfiles\", 'User')
    [Environment]::SetEnvironmentVariable('NOTES_DIR', "$cloudpath" + "\Notes\", 'User')
    [Environment]::SetEnvironmentVariable('PROJECTS_DIR', "$cloudpath" + "\Code\", 'User')
}

### Hostname

function change_hostname {
    $computername = Read-Host -Prompt 'What name do you want? (e.g. ''windesk'')'
    if ($env:computername -ne $computername) {
        Rename-Computer -NewName $computername
    }

    Write-Message 'Restart to take effect.'
}

### Keyboard & mouse settings

function kbd_settings {

    $LanguageList = Get-WinUserLanguageList

    if (-not $LanguageList | Where-Object { $_.InputMethodTips -contains "0409:0000040C" }) {
        if (Ask-Question 'FR keyboard layout not detected, install?') {
            Write-Message 'Adding FR keyboard layout...'
            $LanguageList[0].InputMethodTips.Add('0409:0000040C')
            Set-WinUserLanguageList $LanguageList -Force
            Set-WinDefaultInputMethodOverride -InputTip "0409:0000040C"
        }
    }

    if (Ask-Question 'Remap ctrl to capslock key?') {
        $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
        $kbLayout = "HKLM:\System\CurrentControlSet\Control\Keyboard Layout";

        New-ItemProperty -Path $kbLayout -Name 'Scancode Map' -PropertyType Binary -Value ([byte[]]$hexified);

        Write-Message 'You need to reboot to take effect.'
    }

    Write-Message 'Disabling mouse acceleration...'
    $mousepath = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty -Path $mousepath -Name MouseSpeed -Value 0
    Set-ItemProperty -Path $mousepath -Name MouseThreshold1 -Value 0
    Set-ItemProperty -Path $mousepath -Name MouseThreshold2 -Value 0
}

### Chocolatey

function install_chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

### Packages

function install_choco {
    choco install 7zip
    choco install aria2
    choco install autohotkey
    choco install chatty
    choco install electrum
    choco install emacs
    choco install everything --params '/client-service /efu-association /folder-context-menu /run-on-system-startup /start-menu-shortcuts'
    choco install exiftool
    choco install fd
    choco install ffmpeg
    choco install firefox
    choco install git --params '/GitAndUnixToolsOnPath /NoShellIntegration /NoOpenSSH /NoAutoCrlf /SChannel'
    choco install imagemagick
    choco install keepass
    choco install microsoft-windows-terminal
    choco install mkvtoolnix
    choco install mpv
    choco install nomacs
    choco install obs-studio
    choco install shellcheck
    choco install signal --params '/NoShortcut'
    choco install simplewall
    choco install soundswitch
    choco install steam-client
    choco install streamlink
    choco install synologydrive
    choco install telegram
    choco install thunderbird
    choco install tor-browser
    choco install veracrypt
    choco install yt-dlp

    choco pin add -n brave
    choco pin add -n chatty
    choco pin add -n signal
    choco pin add -n simplewall
    choco pin add -n steam-client
    choco pin add -n telegram
    choco pin add -n thunderbird
    choco pin add -n tor-browser
}

### Packages

function install_winget {

    $packages = @(
        '7zip.7zip',
        'aria2.aria2',
        'AutoHotkey.AutoHotkey',
        'Chatty.Chatty',
        'Synology.DriveClient',
        'Electrum.Electrum',
        'voidtools.Everything',
        'OliverBetz.ExifTool',
        'sharkdp.fd',
        'FeatherWallet.Feather',
        'Gyan.FFmpeg',
        'Mozilla.Firefox',
        'XavierRoche.HTTrack',
        'GnuPG.GnuPG',
        'ImageMagick.ImageMagick',
        'DominikReichl.KeePass',
        'GnuWin32.Make',
        'Microsoft.MouseandKeyboardCenter',
        'MullvadVPN.MullvadVPN',
        'Insecure.Nmap',
        'nomacs.nomacs',
        'OBSProject.OBSStudio',
        'Microsoft.PowerToys',
        'Python.Python.3.12',
        'BurntSushi.ripgrep.MSVC',
        'koalaman.shellcheck',
        'OpenWhisperSystems.Signal',
        'Henry++.simplewall',
        'AntoineAflalo.SoundSwitch',
        'Spotify.Spotify',
        'Streamlink.Streamlink',
        'Valve.Steam',
        'Telegram.TelegramDesktop',
        'IDRIX.VeraCrypt',
        'Oracle.VirtualBox',
        'Microsoft.VisualStudioCode',
        'Microsoft.WindowsTerminal',
        'yt-dlp.yt-dlp'
    )

    if (Ask-Question 'Install WinGet from GitHub (instead of Microsoft Store)?') {
        $API_URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $DOWNLOAD_URL = $(Invoke-RestMethod $API_URL).assets.browser_download_url |
          Where-Object {$_.EndsWith(".msixbundle")}

        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "winget.msixbundle" -UseBasicParsing
        Add-AppxPackage -Path "winget.msixbundle"
        Remove-Item "winget.msixbundle" }

    Write-Message 'Updating sources list...'
    winget source update

    foreach ($p in $packages) {
        if (Ask-Question "Install ${p}?") { winget install -e --id "$p" }
    }

    if (Ask-Question 'Install Emacs?') {
        winget install -e --id 'GNU.Emacs'

        Write-Message 'Excluding Emacs from AV scanning to improve performance...'
        Add-MpPreference -ExclusionPath 'C:\Program Files\Emacs', "$env:APPDATA\.emacs.d"
        Add-MpPreference -ExclusionProcess "C:\Program Files\Emacs\*", 'runemacs.exe', 'emacs.exe', 'emacsclientw.exe', 'emacsclient.exe'
        Add-MpPreference -ExclusionExtension ".el", ".elc", ".eln"
    }

    if (Ask-Question 'Install Git?') {
        winget install -e --id Git.Git --custom '/o:Components=icons,gitlfs /o:PathOption:CmdTools /o:SSHOption=ExternalOpenSSH /o:CRLFOption:CRLFCommitAsIs /o:CURLOption=WinSSL'
    }

    if (Ask-Question 'Install MKVToolNix?') {
        winget install -e --id 'MoritzBunkus.MKVToolNix'

        Write-Message 'Adding MKVToolNix to path...'
        New-Variable -Name 'mkvtnPath' -Value 'C:\Program Files\MKVToolNix'
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        [Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$mkvtnPath", [EnvironmentVariableTarget]::User)
    }

    if (Ask-Question 'Install qBittorrent?') {
        winget install -e --id 'qBittorrent.qBittorrent'

        New-Variable -Name 'PLUGIN_FOLDER' -Value "$HOME\AppData\Local\qBittorrent\nova3\engines"
        New-Item -Force -Path "$PLUGIN_FOLDER" -ItemType directory

        # Official plugins
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/eztv.py'                                           -OutFile "$PLUGIN_FOLDER\eztv.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/limetorrents.py'                                   -OutFile "$PLUGIN_FOLDER\limetorrents.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/piratebay.py'                                      -OutFile "$PLUGIN_FOLDER\piratebay.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/solidtorrents.py'                                  -OutFile "$PLUGIN_FOLDER\solidtorrents.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torlock.py'                                        -OutFile "$PLUGIN_FOLDER\torlock.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentproject.py'                                 -OutFile "$PLUGIN_FOLDER\torrentproject.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/qbittorrent/search-plugins/master/nova3/engines/torrentscsv.py'                                    -OutFile "$PLUGIN_FOLDER\torrentscsv.py"

        # Third Party
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/bitsearch.py'                                           -OutFile "$PLUGIN_FOLDER\bitsearch.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/therarbg.py'                                            -OutFile "$PLUGIN_FOLDER\therarbg.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BurningMop/qBittorrent-Search-Plugins/main/torrentdownloads.py'                                    -OutFile "$PLUGIN_FOLDER\torrentdownloads.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/ettv.py'                                -OutFile "$PLUGIN_FOLDER\ettv.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/glotorrents.py'                         -OutFile "$PLUGIN_FOLDER\glotorrents.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/kickasstorrents.py'                     -OutFile "$PLUGIN_FOLDER\kickasstorrents.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/LightDestory/qBittorrent-Search-Plugins/master/src/engines/snowfl.py'                              -OutFile "$PLUGIN_FOLDER\snowfl.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/dodi_repacks.py'                                                      -OutFile "$PLUGIN_FOLDER\dodi_repacks.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/Bioux1/qbtSearchPlugins/main/fitgirl_repacks.py'                                                   -OutFile "$PLUGIN_FOLDER\fitgirl_repacks.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/6074a7cccb90dfd5c81b7eaddd3138adec7f3377/engines/linuxtracker.py' -OutFile "$PLUGIN_FOLDER\linuxtracker.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MadeOfMagicAndWires/qBit-plugins/master/engines/nyaasi.py'                                         -OutFile "$PLUGIN_FOLDER\nyaasi.py"
        Invoke-WebRequest -Uri 'https://scare.ca/dl/qBittorrent/torrentdownload.py'                                                                                  -OutFile "$PLUGIN_FOLDER\torrentdownload.py"
        Invoke-WebRequest -Uri 'https://scare.ca/dl/qBittorrent/magnetdl.py'                                                                                         -OutFile "$PLUGIN_FOLDER\magnetdl.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/imDMG/qBt_SE/master/engines/rutor.py'                                                              -OutFile "$PLUGIN_FOLDER\rutor.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nbusseneau/qBittorrent-rutracker-plugin/master/rutracker.py'                                       -OutFile "$PLUGIN_FOLDER\rutracker.py"
        Invoke-WebRequest -Uri 'https://gist.githubusercontent.com/scadams/56635407b8dfb8f5f7ede6873922ac8b/raw/f654c10468a0b9945bec9bf31e216993c9b7a961/one337x.py' -OutFile "$PLUGIN_FOLDER\one337x.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AlaaBrahim/qBitTorrent-animetosho-search-plugin/main/animetosho.py'                                -OutFile "$PLUGIN_FOLDER\animetosho.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TuckerWarlock/qbittorrent-search-plugins/main/bt4gprx.com/bt4gprx.py'                              -OutFile "$PLUGIN_FOLDER\bt4gprx.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/MarcBresson/cpasbien/master/src/cpasbien.py'                                                       -OutFile "$PLUGIN_FOLDER\cpasbien.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/BrunoReX/qBittorrent-Search-Plugin-TokyoToshokan/master/tokyotoshokan.py'                          -OutFile "$PLUGIN_FOLDER\tokyotoshokan.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nindogo/qbtSearchScripts/master/torrentgalaxy.py'                                                  -OutFile "$PLUGIN_FOLDER\torrentgalaxy.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/menegop/qbfrench/master/torrent9.py'                                                               -OutFile "$PLUGIN_FOLDER\torrent9.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/amongst-us/qbit-plugins/main/yts_mx/yts_mx.py'                                                     -OutFile "$PLUGIN_FOLDER\yts_mx.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/444995/qbit-search-plugins/main/engines/zooqle.py'                                                 -OutFile "$PLUGIN_FOLDER\zooqle.py"
        Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/CravateRouge/qBittorrentSearchPlugins/master/yggtorrent.py'                                        -OutFile "$PLUGIN_FOLDER\yggtorrent.py"
    }

    if (Ask-Question 'Install Tor Browser?') {
        winget -e --id 'TorProject.TorBrowser'
        Copy-item -Force -Path "C:\Program Files\Tor Browser\Tor Browser.lnk" -Destination "$HOME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Tor Browser.lnk"
    }
}

### mpv

function install_mpv {
    Write-Message 'Creating variables and folders...'

    New-Variable -Name 'mpvInstallPath' -Value 'C:\Program Files\mpv'
    New-Variable -Name 'mpvConfigPath' -Value "$env:APPDATA\mpv"

    New-Item -Force -Path "$mpvInstallPath" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\fonts" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\scripts" -ItemType directory
    New-Item -Force -Path "$mpvConfigPath\scripts\uosc" -ItemType directory

    Write-Message 'Installing latest mpv...'

    Start-BitsTransfer -Source 'https://sourceforge.net/projects/mpv-player-windows/files/bootstrapper.zip' -Destination "$mpvInstallPath\bootstrapper.zip"
    Expand-Archive -Path "$mpvInstallPath\bootstrapper.zip" -DestinationPath "$mpvInstallPath"

    Write-Message 'Adding mpv to path...'
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    [Environment]::SetEnvironmentVariable("PATH", $env:Path + ";$mpvInstallPath", [EnvironmentVariableTarget]::User)

    Push-Location "$mpvInstallPath"
    & "$mpvInstallPath\updater.ps1"
    Pop-Location

    Remove-Item "$mpvInstallPath\bootstrapper.zip"

    Write-Message 'Installing plugins...'

    Start-BitsTransfer -Source 'https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip' -Destination "$mpvConfigPath\uosc.zip"
    Expand-Archive -Path "$mpvConfigPath\uosc.zip" -DestinationPath "$mpvConfigPath"

    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua' -OutFile "$mpvConfigPath\scripts\thumbfast.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/mfcc64/mpv-scripts/master/visualizer.lua' -OutFile "$mpvConfigPath\scripts\visualizer.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/crop.lua' -OutFile "$mpvConfigPath\scripts\crop.lua"
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/occivink/mpv-scripts/master/scripts/encode.lua' -OutFile "$mpvConfigPath\scripts\encode.lua"

    Remove-Item "$mpvConfigPath\uosc.zip"
}

### massgrave activation script

function run_massgrave {
    irm 'https://get.activated.win' | iex
}

### Menu

function usage {
    Write-Host
    Write-Host 'Usage:'
    Write-Host '  gpo               - apply machine and user group policies'
    Write-Host '  uipreferences     - windows explorer & taskbar preferences'
    Write-Host '  nosound           - apply no sounds scheme and turn off startup sound'
    Write-Host '  bitlocker         - change Group Policy settings for BitLocker and encrypts C:'
    Write-Host '  firewall          - firewall rules: block incoming, allow outgoing'
    Write-Host '  ssh               - automatic startup of ssh agent'
    Write-Host '  powersettings     - disable power saving modes on AC power'
    Write-Host '  envar             - setup environment variables'
    Write-Host '  hostname          - change hostname'
    Write-Host '  keyboard          - FR layout, CTRL key remap and no mouse acceleration'
    Write-Host '  chocolatey        - download and sets chocolatey package manager'
    Write-Host '  choco_packages    - download and installs listed packages with chocolatey'
    Write-Host '  winget_packages   - download and installs listed packages with winget'
    Write-Host '  mpv               - install mpv'
    Write-Host '  activate          - run massgrave activation script'
    Write-Host
}

function main {
    $cmd = $args[0]

    # return error if nothing is specified
    if (!$cmd) { usage; exit 1 }

    if ($cmd -eq 'gpo')                 { apply_gpo }
    elseif ($cmd -eq 'uipreferences')   { set_uipreferences }
    elseif ($cmd -eq 'nosound')         { set_nosound }
    elseif ($cmd -eq 'bitlocker')       { enable_bitlocker }
    elseif ($cmd -eq 'firewall')        { set_firewall }
    elseif ($cmd -eq 'ssh')             { set_ssh }
    elseif ($cmd -eq 'powersettings')   { power_settings }
    elseif ($cmd -eq 'envar')           { install_envar }
    elseif ($cmd -eq 'hostname')        { change_hostname }
    elseif ($cmd -eq 'keyboard')        { kbd_settings }
    elseif ($cmd -eq 'chocolatey')      { install_chocolatey }
    elseif ($cmd -eq 'choco_packages')  { install_choco }
    elseif ($cmd -eq 'winget_packages') { install_winget }
    elseif ($cmd -eq 'mpv')             { install_mpv }
    elseif ($cmd -eq 'activate')        { run_massgrave }
    else { usage }
}

main $args[0]
