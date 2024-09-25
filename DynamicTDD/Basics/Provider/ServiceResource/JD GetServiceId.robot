*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${SERVICE1}    P3SERVICE1
${SERVICE2}    P3SERVICE2
${SERVICE3}    P3SERVICE3

${SERVICE11}    P3SERVICE11
${SERVICE12}    P3SERVICE12
${SERVICE13}    P3SERVICE13
@{service_duration}  10  20  30   40   50


@{consumerNoteMandatory}    False   True
@{preInfoEnabled}   False   True   
@{postInfoEnabled}  False   True 
@{serviceType}      virtualService     physicalService 
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09


*** Test Cases ***

JD-TC-GetServiceId-1
        [Documentation]  Get service for a valid provider in Billable domain
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
           
        ${min_pre}=   Random Int   min=1   max=10
        ${Total}=  Random Int   min=11   max=100
        ${min_pre}=  Convert To Number  ${min_pre}  0
        ${Total}=  Convert To Number  ${Total}  0
        ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[2]}  ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${id}    ${resp.json()}
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
     

JD-TC-GetServiceId-2
        [Documentation]   Create and get  service in Non Billable domain
        ${resp}=   Non Billable
        ${description}=  FakerLibrary.sentence
        ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
      
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${EMPTY}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]} 
        

JD-TC-GetServiceId-3-pre_info_&_post_info
        [Documentation]  create and Get physical service for a valid provider in Billable domain
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence
        
        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10101
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes1}=  Create List  ${VirtualcallingMode1}
        Set Test Variable  ${virtualCallingModes1}
        Set Test Variable  ${vstype}  ${vservicetype[1]}

        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Create Service with info  ${SERVICE2}  ${description}  ${service_duration[2]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes1}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${id4}   ${resp.json()}


        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${id}    ${resp.json()}
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


JD-TC-GetServiceId-4-pre_info_&_post_info
        [Documentation]   Create and get  physical service for a valid provider in Non Billable domain
        ${resp}=   Non Billable
        ${description}=  FakerLibrary.sentence
        ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
      
        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20102
        Set Test Variable  ${callingMode1}     ${CallingModes[1]}
        Set Test Variable  ${ModeId1}          ${PUSERPH_id}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes2}=  Create List  ${VirtualcallingMode1}
        Set Test Variable  ${virtualCallingModes2}
        # Set Suite Variable  ${vstype}  ${vservicetype[1]}
        ${vstype}=  Evaluate  random.choice($vservicetype)  random

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE2}  ${description}  ${service_duration[1]}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes2}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]} 
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        Should Not Contain  ${resp.json()}  ${serviceType[0]}


JD-TC-GetServiceId-5-pre_info_&_post_info
        [Documentation]  create and Get virtual service for a valid provider in Billable domain
        ${resp}=   Billable
        ${description}=  FakerLibrary.sentence

        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10101
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes1}=  Create List  ${VirtualcallingMode1}
        Set Test Variable  ${virtualCallingModes1}
        Set Test Variable  ${vstype}  ${vservicetype[1]}

        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        
        ${resp}=  Create Service with info  ${SERVICE3}  ${description}  ${service_duration[2]}  ${bool[1]}  ${notifytype[2]}  ${min_pre}  ${Total}  ${status[0]}  ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes1}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${id4}   ${resp.json()}


        Should Be Equal As Strings  ${resp.status_code}  200 
        Set Suite Variable  ${id}    ${resp.json()}
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${service_duration[2]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}   totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


JD-TC-GetServiceId-6-pre_info_&_post_info
        [Documentation]   Create and get  virtual service for a valid provider in Non Billable domain
        ${resp}=   Non Billable
        ${description}=  FakerLibrary.sentence
        ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
      
        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+20102
        Set Test Variable  ${callingMode1}     ${CallingModes[1]}
        Set Suite Variable  ${ModeId1}          ${PUSERPH_id}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   countryCode=${countryCodes[0]}  status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes2}=  Create List  ${VirtualcallingMode1}
        Set Test Variable  ${virtualCallingModes2}
        Set Suite Variable  ${vstype}  ${vservicetype[0]}
        # ${vstype}=  Evaluate  random.choice($vservicetype)  random
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_Pid1}   status=ACTIVE    instructions=${Desc1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERPH_id}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${Desc1} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE3}  ${description}  ${service_duration[1]}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${EMPTY}  ${status[0]}  ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes2}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]} 
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        

JD-TC-GetServiceId-UH1
    [Documentation]   Get  service by login as consumer
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME10}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${accountId}=  get_acc_id  ${HLPUSERNAME10}
    Set Suite Variable    ${accountId} 

    ${PH_Number}    Random Number 	       digits=5 
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable    ${consumerPhone}  555${PH_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/proconnum.txt  ${SUITE NAME} - ${TEST NAME} - ${consumerPhone}${\n}
    ${fname}=   FakerLibrary.first_name
    ${lname}=    FakerLibrary.last_name
    Set Test Variable      ${fname}
    Set Test Variable      ${lname}  
    ${dob}=    FakerLibrary.Date
    ${permanentAddress1}=  FakerLibrary.address
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${consumerEmail}  ${C_Email}${consumerPhone}${fname}.${test_mail}

    ${resp}=  AddCustomer  ${consumerPhone}  firstName=${fname}   lastName=${lname}  address=${permanentAddress1}   gender=${gender}  dob=${dob}  email=${consumerEmail}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ageyrs}  ${agemonths}=  db.calculate_age_years_months     ${dob}

    ${resp}=  GetCustomer  phoneNo-eq=${consumerPhone}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${consumerId}  ${resp.json()[0]['id']}
    ${fullName}   Set Variable    ${fname} ${lname}
    Set Test Variable  ${fullName}

    ${resp}=  Provider Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['id']}

    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetServiceId-UH2
    [Documentation]  Get service without login
    ${resp}=   Get Service By Id  ${id}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-GetServiceId-UH3
    [Documentation]  Get details of another provider's service
    clear_service       ${PUSERNAME168}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME168}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False']
    ${resp}=  Create Service  ${SERVICE1}  ${description}   30  ACTIVE  Waitlist    ${notify}    ${notifytype}  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${id1}    ${resp.json()}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME158}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service By Id  ${id1}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"


JD-TC-GetServiceId-UH4
    [Documentation]    Get service by invalid id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME168}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service By Id  0
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${NO_SUCH_SERVICE}"



*** Keywords ***
Billable
      ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE   ${length}
            
        clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  Get Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Toggle Department Disable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END 
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Exit For Loop IF     '${check}' == 'True'

    END
   

Non Billable         
       


        ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE    ${length}
        clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  Get Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Toggle Department Disable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END 
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Exit For Loop IF     '${check}' == 'False'
       
     END 