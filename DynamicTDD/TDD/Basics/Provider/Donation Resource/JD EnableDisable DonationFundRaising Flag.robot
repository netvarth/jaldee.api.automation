***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Donation
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
@{multiples}  10  20  30   40   50
${SERVICE1}   MakeUp
${SERVICE2}   Coloring
${SERVICE3}   Painting
${DisplayName1}   item1_DisplayName


***Test Cases***

JD-TC-EnableDisableDonationFundraisingFlag-1
     [Documentation]  Enable and disable DonationFundRaising Flag
     ${resp}=   Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD} 
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200
     
     delete_donation_service  ${PUSERNAME33}
     clear_service   ${PUSERNAME33}
     clear_queue      ${PUSERNAME33}
     clear_location   ${PUSERNAME33}
     ${resp}=   Create Sample Location
     Set Suite Variable    ${loc_id1}    ${resp}  
     ${description}=  FakerLibrary.sentence
     ${min_don_amt1}=   Random Int   min=100   max=500
     ${mod}=  Evaluate  ${min_don_amt1}%${multiples[0]}
     ${min_don_amt}=  Evaluate  ${min_don_amt1}-${mod}
     ${max_don_amt1}=   Random Int   min=5000   max=10000
     ${mod1}=  Evaluate  ${max_don_amt1}%${multiples[0]}
     ${max_don_amt}=  Evaluate  ${max_don_amt1}-${mod1}
     ${min_don_amt}=  Convert To Number  ${min_don_amt}  1
     ${max_don_amt}=  Convert To Number  ${max_don_amt}  1
     ${service_duration}=   Random Int   min=10   max=50
     ${total_amnt}=   Random Int   min=100   max=500

     ${resp}=  Create Donation Service  ${SERVICE1}   ${description}   ${service_duration}   ${btype}   ${bool[1]}    ${notifytype[2]}   ${total_amnt}    ${bool[0]}  ${bool[0]}  ${service_type[0]}  ${min_don_amt}  ${max_don_amt}  ${multiples[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200  
     Set Suite Variable  ${sid1}  ${resp.json()}

     ${resp}=  Get Account Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  donationFundRaising=${bool[0]}

     ${resp}=  DonationFundRaising flag  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Account Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  donationFundRaising=${bool[1]}

     ${resp}=  DonationFundRaising flag  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Account Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  donationFundRaising=${bool[0]}

JD-TC-EnableDisableDonationFundraisingFlag -UH1
     [Documentation]   Provider enable a User without login      
     ${resp}=  DonationFundRaising flag  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-EnableDisableDonationFundraisingFlag -UH2
    [Documentation]   Consumer enable a user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  DonationFundRaising flag  ${toggle[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-EnableDisableDonationFundraisingFlag-UH3
     [Documentation]  Enable a already enabled donation flag
     ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  DonationFundRaising flag  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  DonationFundRaising flag  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${DONATION_FUND_RAISING_ALREDY_ENABLED}"

JD-TC-EnableDisableDonationFundraisingFlag-UH4
     [Documentation]  Disable a already disabled donation flag 
     ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  DonationFundRaising flag  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  DonationFundRaising flag  ${toggle[1]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${DONATION_FUND_RAISING_ALREDY_DISABLED}"

JD-TC-EnableDisableDonationFundraisingFlag-UH5
     [Documentation]  Enable and disable DonationFundRaising Flag without creating donation service.
     ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200
     
     delete_donation_service  ${PUSERNAME35}
     
     ${resp}=  Get Account Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  donationFundRaising=${bool[0]}

     ${resp}=  DonationFundRaising flag  ${toggle[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${CAUSES_REQUIRED}"  

