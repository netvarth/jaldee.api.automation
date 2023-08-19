*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        TAX
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-Get Tax Percentage-1
       [Documentation]   Get Tax valid provider
       ${resp}=   ProviderLogin  ${PUSERNAME18}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${gstper}=  Random Element  ${gstpercentage}
       ${GST_num}  ${pan_num}=   Generate_gst_number   ${Container_id}
       ${resp}=  Update Tax Percentage  ${gstper}  ${GST_num}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Enable Tax
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Tax Percentage 
       Should Be Equal As Strings    ${resp.status_code}   200
       Should Be Equal As Strings   ${resp.json()['taxPercentage']}   ${gstper}
       Should Be Equal As Strings   ${resp.json()['gstNumber']}   ${GST_num}
JD-TC-Get Tax Percentage-UH3
       [Documentation]   consumer try to Get Tax
       ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
       Should Be Equal As Strings  ${resp.status_code}  200   
       ${resp}=   Get Tax Percentage    
       Should Be Equal As Strings    ${resp.status_code}   401 
       Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Get Tax Percentage-UH4
       [Documentation]   without login to update Tax      
       ${resp}=   Get Tax Percentage   
       Should Be Equal As Strings    ${resp.status_code}   419 
       Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"       