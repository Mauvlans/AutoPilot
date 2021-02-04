# ***************************************************************************
#
# Purpose: Script to Validate Endpoint avaliblilty for Autopilot. 
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

$hash = @{
    'go.microsoft.com' = '443'
    'login.live.com' = '443'
    'crl.microsoft.com' = '443'
    'activation.sls.microsoft.com' = '443'
    'validation.sls.microsoft.com' = '443'
    'activation-v2.sls.microsoft.com' = '443'
    'validation-v2.sls.microsoft.com' = '443'
    'displaycatalog.mp.microsoft.com' = '443'
    'displaycatalog.md.mp.microsoft.com' = '443'
    'licensing.mp.microsoft.com' = '443'
    'licensing.md.mp.microsoft.com' = '443'
    'purchase.mp.microsoft.com' = '443'
    'login.microsoftonline.com' = '443'
    'account.live.com' = '443'
    'signup.live.com' = '443'
    'account.azureedge.net' = '443'
    'secure.aadcdn.microsoftonline-p.com' = '443'
    'enterpriseregistration.windows.net' = '443'
    'portal.manage.microsoft.com' = '443'
    'm.manage.microsoft.com' = '443'
    'sts.manage.microsoft.com' = '443'
    'Manage.microsoft.com' = '443'
    'i.manage.microsoft.com' = '443'
    'r.manage.microsoft.com' = '443'
    'a.manage.microsoft.com' = '443'
    'EnterpriseEnrollment.manage.microsoft.com' = '443'
    'EnterpriseEnrollment-s.manage.microsoft.com' = '443'
    'portal.fei.msua01.manage.microsoft.com' = '443'
    'm.fei.msua01.manage.microsoft.com' = '443'
    'fef.msua06.manage.microsoft.com' = '443'
    'enrollment.manage.microsoft.com' = '443'
    'msftconnecttest.com' = '443'
    'ekop.intel.com' = '443'
    'ekcert.spserv.microsoft.com' = '443'
    'ftpm.amd.com' = '443'
    }

    ForEach ($h in $hash.GetEnumerator() ){

    try{
        
        if (Test-NetConnection -ComputerName $($h.Name) -Port $($h.Value) -InformationLevel Quiet -ErrorAction Stop){
            
            Write-Host "$($h.Name) = PASS" -ForegroundColor Green

        }else{
            
            Write-Host "$($h.Name) = FAILED" -ForegroundColor Red
        
        }
    
    }catch{
         
    }
    }