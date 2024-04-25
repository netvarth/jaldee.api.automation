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

JD-TC-HowDoYouHear1

    [Documentation]  Add how do you hear us potion without sales chanel code. Used other sales chanel type
    # ${scid}=  FakerLibrary.Word
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
    ${pri_ph}=  Evaluate  ${PUSERNAME}+30012
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
    
    clear_ScRepTable  ABCD12
    clear_ScTable     ${pri_ph}
    
   

    ${resp}=  Create SA SalesChannel    ABCD12    ${pro_disc_jd}   ${pro_disc_dur}   ${scname}   ${contact_fname}    ${contact_lname}    ${address}    ${city}    ${metro}    ${state}   ${latti}   ${longi}   ${radius}   ${postcode}   ${Sctype[2]}  ${pri_ph}   ${alt_ph1}   ${alt_ph2}    ${comm_dur}   ${comm_pct}    ${pri_email}   ${alt_email1}   ${alt_email2}   ${bonusPeriod[0]}    ${id}   ${targetCount}   ${rate}   ${private_note}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    


    ${resp}=  Create Sales Channel Rep   ABCD12   ${rep_fname}  ${rep_lname}     ${alt_ph1}    ${alt_email1}   ${kyc[0]}   ${kycDoneBy}    ${area_rep}    ${repcode}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable   ${sales_channel_repid}    ${resp.json()} 


    Set Suite Variable  ${sc_code}     ABCD12-${scDiscCodes}-${repcode}-0

    Log  ${sc_code}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_M}=  Evaluate  ${PUSERNAME}+80005
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create HowDoYouHearUs    ${PUSERNAME_M}   ${HowDoYouHear[0]}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    ${resp}=  Account Set Credential  ${PUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_M}${\n}   
    ${resp}=   Get SalesChannel
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.content}    ${EMPTY}

    ${resp}=  ProviderKeywords.Get SalesChannelByID    ABCD12
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    
    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-HowDoYouHear2

    [Documentation]   Add how do you hear us with sales chanel type abd sales chanel code

    # ${scid}=  FakerLibrary.Word
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
    ${pri_ph}=  Evaluate  ${PUSERNAME}+1002041
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
    ${sc_cd}=  FakerLibrary.Word
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

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
    ${pro_disc_jd}=  FakerLibrary.Random Int  min=${minProDiscFromJaldee}    max=${maxProDiscFromJaldee}
    ${pro_disc_dur}=  FakerLibrary.Random Int   min=${minProJaldeeDiscDuration}     max=${maxProJaldeeDiscDuration}


    clear_ScRepTable  ABCD13
    clear_ScTable     ${pri_ph}



    ${resp}=  Create SA SalesChannel   ABCD13   ${pro_disc_jd}   ${pro_disc_dur}   ${scname}   ${contact_fname}    ${contact_lname}    ${address}    ${city}    ${metro}    ${state}   ${latti}   ${longi}   ${radius}   ${postcode}   ${Sctype[2]}  ${pri_ph}   ${alt_ph1}   ${alt_ph2}    ${comm_dur}   ${comm_pct}    ${pri_email}   ${alt_email1}   ${alt_email2}   ${bonusPeriod[0]}    ${id}   ${targetCount}   ${rate}   ${private_note}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_id}   ${resp.json()} 


    ${resp}=  Create Sales Channel Rep   ABCD13   ${rep_fname}  ${rep_lname}     ${alt_ph1}    ${alt_email1}   ${kyc[0]}   ${kycDoneBy}    ${area_rep}    ${repcode}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_repid}   ${resp.json()} 


    Set Suite Variable  ${sc_code}     ABCD13-${scDiscCodes}-${repcode}-0

    Log  ${sc_code}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_M}=  Evaluate  ${PUSERNAME}+15889
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=  Create HowDoYouHearUs    ${PUSERNAME_M}   ${HowDoYouHear[4]}   ${sc_code}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    ${resp}=  Account Set Credential  ${PUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_M}${\n}   
     ${resp}=   Get SalesChannel
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   "${resp.json()}"    "${sc_code}" 

    ${resp}=  ProviderKeywords.Get SalesChannelByID    ABCD13
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings    ${resp.json()[salesChannelCode]}     '${sc_code}' 


JD-TC-HowDoYouHear_UH1


    [Documentation]    Setting how do you hear us using Sales Rep type without Sales chanel code
    # ${scid}=  FakerLibrary.Word
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
    ${pri_ph}=  Evaluate  ${PUSERNAME}+1002042
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
    ${sc_cd}=  FakerLibrary.Word
    
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

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
    ${comm_pct}=     FakerLibrary.Random Int  min=${minComModelPct}   max=${comModelMaxPct}
    ${pro_disc_jd}=  FakerLibrary.Random Int  min=${minProDiscFromJaldee}   max=${maxProDiscFromJaldee}
    ${pro_disc_dur}=  FakerLibrary.Random Int   min=${minProJaldeeDiscDuration}    max=${maxProJaldeeDiscDuration}
    
    clear_ScRepTable  ABCD14
    clear_ScTable     ${pri_ph}

    ${resp}=  Create SA SalesChannel    ABCD14    ${pro_disc_jd}   ${pro_disc_dur}   ${scname}   ${contact_fname}    ${contact_lname}    ${address}    ${city}    ${metro}    ${state}   ${latti}   ${longi}   ${radius}   ${postcode}   ${Sctype[2]}  ${pri_ph}   ${alt_ph1}   ${alt_ph2}    ${comm_dur}   ${comm_pct}    ${pri_email}   ${alt_email1}   ${alt_email2}   ${bonusPeriod[0]}    ${id}   ${targetCount}   ${rate}   ${private_note}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_id}   ${resp.json()} 


    ${resp}=  Create Sales Channel Rep   ABCD14   ${rep_fname}  ${rep_lname}     ${alt_ph1}    ${alt_email1}   ${kyc[0]}   ${kycDoneBy}    ${area_rep}    ${repcode}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_repid}   ${resp.json()} 


    Set Suite Variable  ${sc_code}     ABCD14-${scDiscCodes}-${repcode}-0

    Log  ${sc_code}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_M}=  Evaluate  ${PUSERNAME}+800045
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create HowDoYouHearUs    ${PUSERNAME_M}   ${HowDoYouHear[4]}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422  
    ${resp}=  Account Set Credential  ${PUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_M}${\n}   
    ${resp}=   Get SalesChannel
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.content}    ${EMPTY} 

    ${resp}=  ProviderKeywords.Get SalesChannelByID    ABCD14
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-HowDoYouHear_UH2

    [Documentation]   Setting how do you hear us using other type with Sales chanel code
    # ${sccid}=  FakerLibrary.Word
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
    ${pri_ph}=  Evaluate  ${PUSERNAME}+102043
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
    ${sc_cd}=  FakerLibrary.Word
    clear_ScRepTable    ABCD15
    clear_ScTable     ${pri_ph}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  

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
    ${comm_pct}=     FakerLibrary.Random Int  min=${minComModelPct}     max=${comModelMaxPct}
    ${pro_disc_jd}=  FakerLibrary.Random Int  min=${minProDiscFromJaldee}     max=${maxProDiscFromJaldee}
    ${pro_disc_dur}=  FakerLibrary.Random Int   min=${minProJaldeeDiscDuration}     max=${maxProJaldeeDiscDuration}

    clear_ScRepTable  ABCD15
    clear_ScTable     ${pri_ph}

    ${resp}=  Create SA SalesChannel    ABCD15    ${pro_disc_jd}   ${pro_disc_dur}   ${scname}   ${contact_fname}    ${contact_lname}    ${address}    ${city}    ${metro}    ${state}   ${latti}   ${longi}   ${radius}   ${postcode}   ${Sctype[2]}  ${pri_ph}   ${alt_ph1}   ${alt_ph2}    ${comm_dur}   ${comm_pct}    ${pri_email}   ${alt_email1}   ${alt_email2}   ${bonusPeriod[0]}    ${id}   ${targetCount}   ${rate}   ${private_note}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_id}   ${resp.json()} 


    ${resp}=  Create Sales Channel Rep   ABCD15   ${rep_fname}  ${rep_lname}     ${alt_ph1}    ${alt_email1}   ${kyc[0]}   ${kycDoneBy}    ${area_rep}    ${repcode}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${sales_channel_repid}   ${resp.json()} 


    Set Suite Variable  ${sc_code}     ABCD15-${scDiscCodes}-${repcode}-0

    Log  ${sc_code}

    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_M}=  Evaluate  ${PUSERNAME}+800566
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_M}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_M}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create HowDoYouHearUs    ${PUSERNAME_M}   ${HowDoYouHear[2]}    ${sc_code} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    ${resp}=  Account Set Credential  ${PUSERNAME_M}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_M}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_M}${\n}   
    ${resp}=   Get SalesChannel
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.content}    ${EMPTY} 

    ${resp}=  ProviderKeywords.Get SalesChannelByID    ABCD15
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=   Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   