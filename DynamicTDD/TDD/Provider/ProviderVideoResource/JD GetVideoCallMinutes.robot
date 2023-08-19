*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Video Call
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py



*** Test Cases ***

JD-TC-GetVideoCallMinutes-1

    [Documentation]  Get Video Call minutes of a provider(by default).

    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "00 Hour 00 Minutes and 00 Seconds "


JD-TC-GetVideoCallMinutes-2

    [Documentation]  Get Video Call minutes of a provider(add on added).

    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "04 Hour 00 Minutes and 00 Seconds "

   

JD-TC-GetVideoCallMinutes-3

    [Documentation]  Get Video Call minutes of a provider(add on added).

    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "10 Hour 00 Minutes and 00 Seconds "

   

JD-TC-GetVideoCallMinutes-4

    [Documentation]  Get Video Call minutes of a provider(add on added).

    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${up_addons}=   Get upgradable addons
    Log  ${up_addons.json()}
    Should Be Equal As Strings    ${up_addons.status_code}   200
    Set Suite Variable  ${addons}  ${up_addons.json()}  

    ${addon_list}=  addons_all_license_applicable  ${addons}
    Log  ${addon_list}
    ${resp}=  Add addon  ${addon_list[3][0]['addon_id']}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Video Call Minutes 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.content}   "14 Hour 00 Minutes and 00 Seconds "

   
   