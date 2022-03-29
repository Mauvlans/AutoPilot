# ***************************************************************************
#
# Purpose: Set DNS Suffix on local workstations, if running from intune run
# in 64bit shell.
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

Set-DnsClientGlobalSetting -SuffixSearchList @("corp.contoso.com", "na.corp.contoso.com")
