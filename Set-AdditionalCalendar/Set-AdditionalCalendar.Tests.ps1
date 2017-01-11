Describe 'Generic script tests' {
    $null = . "$(Join-Path -Path $PSScriptRoot -ChildPath Set-AdditionalCalendar.ps1)"
    It 'Script should exist' {
        Get-Item "$(Join-Path -Path $PSScriptRoot -ChildPath Set-AdditionalCalendar.ps1)" | Should Exist
    }
    It "Function 'Set-AdditionalCalendar' should exist and exported" {
        Get-Command -Name "Set-AdditionalCalendar" | Should Not BeNullorEmpty
    }
}
Describe "Function 'Set-AdditionalCalendar' checks" {
    Context 'Common help sections ' {
        Write-Output Synopsis Description Alertset Examples RelatedLinks | ForEach-Object {
            It "Comment based help should contain: $_" {
                (Get-Help -Name Set-AdditionalCalendar).$_ | Should Not BeNullorEmpty
            }
        }
    }
    Context "Verifying Off parameter configuration" {
        $Parameter = Get-Help Set-AdditionalCalendar -Parameter Off
        It "Should be mandatory" {
            $Parameter.required | Should be true
        }
        It "Should be of type SwitchParameter" {
            $Parameter.Type.name | Should be SwitchParameter
        }
        It "Should have comment-based help defined" {
            $Parameter.Description | Should not BeNullorEmpty
        }
        It "Should have 'False' set as default value" {
            $Parameter.defaultValue | Should Be False
        }
        It "Should be in Additional Calendar Off parameter set" {
            (Get-Command Set-AdditionalCalendar).ParameterSets.parameters.where{$_.name -eq $Parameter.Name} | Should Not BeNullorEmpty
        }
    }
    Context "Verifying SimplifiedLunar parameter configuration" {
        $Parameter = Get-Help Set-AdditionalCalendar -Parameter SimplifiedLunar
        It "Should be mandatory" {
            $Parameter.required | Should be true
        }
        It "Should be of type SwitchParameter" {
            $Parameter.Type.name | Should be SwitchParameter
        }
        It "Should have comment-based help defined" {
            $Parameter.Description | Should not BeNullorEmpty
        }
        It "Should have 'False' set as default value" {
            $Parameter.defaultValue | Should Be False
        }
        It "Should be in Simplified Lunar Calendar parameter set" {
            (Get-Command Set-AdditionalCalendar).ParameterSets.parameters.where{$_.name -eq $Parameter.Name} | Should Not BeNullorEmpty
        }
    }
    Context "Verifying TraditionalLunar parameter configuration" {
        $Parameter = Get-Help Set-AdditionalCalendar -Parameter TraditionalLunar
        It "Should be mandatory" {
            $Parameter.required | Should be true
        }
        It "Should be of type SwitchParameter" {
            $Parameter.Type.name | Should be SwitchParameter
        }
        It "Should have comment-based help defined" {
            $Parameter.Description | Should not BeNullorEmpty
        }
        It "Should have 'False' set as default value" {
            $Parameter.defaultValue | Should Be False
        }
        It "Should be in Traditional Lunar Calendar parameter set" {
            (Get-Command Set-AdditionalCalendar).ParameterSets.parameters.where{$_.name -eq $Parameter.Name} | Should Not BeNullorEmpty
        }
    }
}