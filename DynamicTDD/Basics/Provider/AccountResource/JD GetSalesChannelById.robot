*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***

*** Test Cases ***

JD-TC-Get SalesChannelById1

    [Documentation]  Add how do you here us potion
    ${city}=  FakerLibrary.Word
    ${metro}=  FakerLibrary.Word
    ${state}=  FakerLibrary.Word
    ${radius}=  FakerLibrary.Random Int  min=1  max=100
    ${scname}=   FakerLibrary.name
    ${contact_fname}=  FakerLibrary.first_name
    ${contact_lname}=  FakerLibrary.last_name
    ${rep_fname}=  FakerLibrary.first_name
    ${rep_lname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${latti}=  get_latitude
    Set Suite Variable   ${latti}
    ${longi}=  get_longitude
    Set Suite Variable   ${longi}
    ${postcode}=  FakerLibrary.postcode
    ${pri_ph}=  Evaluate  ${PUSERNAME}+30134
    ${alt_ph1}=  Evaluate  ${PUSERNAME}+1008006
    ${alt_ph2}=  Evaluate  ${PUSERNAME}+1008007
    ${pri_email}=    Set Variable  ${contact_lname}.${test_mail}
    ${alt_email1}=  Set Variable   ${contact_fname}.${test_mail}
    ${alt_email2}=  Set Variable   ${contact_lname}.${test_mail}
    ${private_note}=   FakerLibrary.sentence
    ${model_code}=    FakerLibrary.Word
    ${kycDoneBy}=   FakerLibrary.name
    ${repcode}=   FakerLibrary.Word
    ${area_rep}=     FakerLibrary.Word 

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
*** comment ***
    ${resp}=  Get SC Configuration
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable   ${id}    ${resp.json()['bonusRates'][0]['id']}
    Set Suite Variable   ${targetCount}    ${resp.json()['bonusRates'][0]['targetCount']}
    Set Suite Variable   ${rate}    ${resp.json()['bonusRates'][0]['rate']}
   
    Set Suite Variable   ${code}    ${resp.json()['scDiscCodes'][0]['code']}
    Set Suite Variable   ${value}    ${resp.json()['scDiscCodes'][0]['value']}
    Set Suite Variable   ${scDiscCodes}    ${code}${value} 
    
    
    Set Suite Variable   ${maxProDiscFromJaldee}     ${resp.json()['maxProDiscFromJaldee']}
    Set Suite Variable   ${maxProJaldeeDiscDuration}     ${resp.json()['maxProJaldeeDiscDuration']}
    Set Suite Variable   ${comModelMaxPct}     ${resp.json()['comModelMaxPct']}
    Set Suite Variable   ${comModelMaxTillMonth}     ${resp.json()['comModelMaxTillMonth']}

    Set Suite Variable   ${minProDiscFromJaldee}   ${resp.json()['defaultProDiscFromJaldee']}
    Set Suite Variable   ${minProJaldeeDiscDuration}   ${resp.json()['defaultProJaldeeDiscDuration']}
    Set Suite Variable   ${minComModelPct}        ${resp.json()['defaultComModelPct']}

       
    ${comm_dur}=     FakerLibrary.Random Int  min=1  max=${comModelMaxTillMonth}
    ${comm_pct}=     FakerLibrary.Random Int  min=${minComModelPct}    max=${comModelMaxPct}
    ${pro_disc_jd}=  FakerLibrary.Random Int  min=${minProDiscFromJaldee}     max=${maxProDiscFromJaldee}
    ${pro_disc_dur}=  FakerLibrary.Random Int   min=${minProJaldeeDiscDuration}     max=${maxProJaldeeDiscDuration}
    
    clear_ScRepTable  ABCD
    clear_ScTable     ${pri_ph}

    ${resp}=  Create SA SalesChannel    ABCD    ${pro_disc_jd}   ${pro_disc_dur}   ${scname}   ${contact_fname}    ${contact_lname}    ${address}    ${city}    ${metro}    ${state}   ${latti}   ${longi}   ${radius}   ${postcode}   ${Sctype[2]}  ${pri_ph}   ${alt_ph1}   ${alt_ph2}    ${comm_dur}   ${comm_pct}    ${pri_email}   ${alt_email1}   ${alt_email2}   ${bonusPeriod[0]}    ${id}   ${targetCount}   ${rate}   ${private_note}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable   ${sales_channel_id}    ${resp.json()} 


    ${resp}=  Create Sales Channel Rep   ABCD   ${rep_fname}  ${rep_lname}     ${alt_ph1}    ${alt_email1}   ${kyc[0]}   ${kycDoneBy}    ${area_rep}    ${repcode}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable   ${sales_channel_repid}    ${resp.json()} 
    Set Suite Variable  ${sc_code}     ABCD-${scDiscCodes}-${repcode}-0
    Log  ${sc_code}
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200  

    clear_ssc_code  ${PUSERNAME114}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME114}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add SalesChannel   ${sc_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderKeywords.Get SalesChannelByID   ABCD 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    


JD-TC-Get SalesChannelById1-UH1

    [Documentation]  get saleschannelById with invalid id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderKeywords.Get SalesChannelByID   ABHDDFLJ
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Get SalesChannelById1-UH2

    [Documentation]  consumer check saleschannel id
    ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderKeywords.Get SalesChannelByID   ABCD 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-Get SalesChannelById1-UH3

    [Documentation]  check getsalechannel without Login
    ${resp}=  ProviderKeywords.Get SalesChannelByID   ABCD 
    Should Be Equal As Strings  ${resp.status_code}  200
    

JD-TC-Get SalesChannelById1-UH4

    [Documentation]  check a provider's sales chennel details another provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderKeywords.Get SalesChannelByID   ABCD 
    Should Be Equal As Strings  ${resp.status_code}  200