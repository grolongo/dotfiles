@{
    IncludeRules=@('PSUseApprovedVerbs',
                   'PSReservedCmdletChar',
                   'PSReservedParams',
                   'PSShouldProcess',
                   'PSUseShouldProcessForStateChangingFunctions',
                   'PSUseSingularNouns',
                   'PSMissingModuleManifestField',
                   'PSAvoidDefaultValueSwitchParameter',
                   'PSAvoidUsingCmdletAliases',
                   'PSAvoidUsingWMICmdlet',
                   'PSAvoidUsingEmptyCatchBlock',
                   'PSUseCmdletCorrectly',
                   'PSUseShouldProcessForStateChangingFunctions',
                   'PSAvoidUsingPositionalParameters',
                   'PSAvoidGlobalVars',
                   'PSUseDeclaredVarsMoreThanAssignments',
                   'PSAvoidUsingInvokeExpression',
                   'PSAvoidUsingPlainTextForPassword',
                   'PSAvoidUsingComputerNameHardcoded',
                   'PSUsePSCredentialType',
                   'PSDSC*',
                   'PSProvideCommentHelp',
                   'PSAvoidUsingWriteHost',
                   'PSAvoidUsingConvertToSecureStringWithPlainText',
                   'PSAvoidUsingUserNameAndPasswordParams',
                   'PSPlaceOpenBrace',
                   'PSPlaceCloseBrace',
                   'PSUseConsistentWhitespace',
                   'PSUseConsistentIndentation',
                   'PSAlignAssignmentStatement',
                   'PSUseCorrectCasing'
                  )

    Rules        = @{
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable          = $true
            Kind            = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $true
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
            IgnoreAssignmentOperatorInsideHashTable = $true
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing     = @{
            Enable             = $true
        }
    }
}
