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
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 




*** Variables ***
@{service_duration}  10  20  30   40   50
${SERVICE1}   P1SERVICE111 
${SERVICE2}   P1SERVICE222
${SERVICE3}   P1SERVICE333
@{status}   ACTIVE   INACTIVE
@{consumerNoteMandatory}    False   True
@{preInfoEnabled}   False   True   
@{postInfoEnabled}  False   True 
${start1}         20
${start2}         50
${start3}         80
${loc}          TGR 
${queue1}     QUEUE1
${self}     0
@{service_names}
@{provider_list}
@{dom_list}
@{multiloc_providers}
@{serviceType}      virtualService     physicalService 
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
@{service_names}



*** Keywords ***

# MultiLocation

#         ${multilocdoms}=  get_mutilocation_domains
#         Log  ${multilocdoms}
#         ${domlen}=  Get Length   ${multilocdoms}
#         ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
#         ${len}=   Split to lines  ${resp}
#         ${length}=  Get Length   ${len}

#         FOR   ${i}  IN RANGE   ${domlen}
#                 ${dom}=  Convert To String   ${multilocdoms[${i}]['domain']}
#                 Append To List   ${dom_list}  ${dom}
#         END
#         Log   ${dom_list}

#         FOR   ${a}  IN RANGE   ${length-1}    
#                 ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
#                 Log   ${resp.json()}
#                 Should Be Equal As Strings    ${resp.status_code}    200
#                 clear_customer   ${PUSERNAME${a}}
#                 ${domain}=   Set Variable    ${resp.json()['sector']}
#                 ${subdomain}=    Set Variable      ${resp.json()['subSector']}
#                 Log  ${dom_list}
#                 ${status} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${dom_list}  ${domain}
#                 Log Many  ${status} 	${value}
#                 Run Keyword If  '${status}' == 'PASS'   Append To List   ${multiloc_providers}  ${PUSERNAME${a}}
#                 ${resp}=  Get Waitlist Settings
#                 Log   ${resp.json()}
#                 Should Be Equal As Strings    ${resp.status_code}    200
#                 ${resp}=  Get Waitlist Settings
#     Log  ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     IF  ${resp.json()['filterByDept']}==${bool[1]}
#         ${resp}=  Enable Disable Department  ${toggle[1]}
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200

#     END
#         END
#         RETURN  ${multiloc_providers}



*** Test Cases ***
JD-TC-Create Service With info-1
        [Documentation]   Create  a Virtual service for a valid provider in Billable domain
        ${resp}=   Billable  ${start1}
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME120}
        Set Suite Variable   ${ZOOM_id0}
        
        ${PUSERPH_id}=  Evaluate  ${PUSERNAME}+10101
        ${ZOOM_Pid1}=  Format String  ${ZOOM_url}  ${PUSERPH_id}
        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid1}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Desc1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Desc1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable  ${virtualCallingModes}
        # ${vstype}=  Evaluate  random.choice($vservicetype)  random
        Set Suite Variable  ${vstype}  ${vservicetype[1]}

        # ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
        # Log  ${resp.json()}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  serviceType=${serviceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}  provider=0  consumerNoteMandatory=${consumerNoteMandatory[0]}  consumerNoteTitle=${consumerNoteTitle}  preInfoEnabled=${preInfoEnabled[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]} 
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Create Service With info-2
        [Documentation]   Create  Physical service for a valid provider in Billable domain
        ${resp}=   Billable  ${start1}
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}

        
        # ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
        # Log  ${resp.json()}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  serviceType=${serviceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}  provider=0  consumerNoteMandatory=${consumerNoteMandatory[0]}  consumerNoteTitle=${consumerNoteTitle}  preInfoEnabled=${preInfoEnabled[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]} 
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Create Service With info-3

        [Documentation]   Create  Virtual service for a valid provider in Non Billable domain
        ${resp}=   Non Billable
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  serviceType=${serviceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}  provider=0  consumerNoteMandatory=${consumerNoteMandatory[0]}  consumerNoteTitle=${consumerNoteTitle}  preInfoEnabled=${preInfoEnabled[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${postInfoEnabled[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[2]}   totalAmount=0.0   status=${status[0]}   bType=${btype}  isPrePayment=${bool[0]}   
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
 


JD-TC-Create Service With info-4
        [Documentation]   Create  Physical service for a valid provider in Non Billable domain
        ${resp}=   Non Billable
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${EMPTY}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[2]}   totalAmount=0.0   status=${status[0]}   bType=${btype}  isPrePayment=${bool[0]}   
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Create Service With info-5
        [Documentation]     Create  a service for a valid provider with service name same as another provider
        ${resp}=   Billable  ${start2}
        # clear_service      ${resp}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence

        ${description}=  FakerLibrary.sentence
        ${min_pre1}=   Random Int   min=1   max=10
        ${Total1}=   Random Int   min=100   max=500
        ${min_pre1}=  Convert To Number  ${min_pre1}  1
        ${Total1}=  Convert To Number  ${Total1}  1
        
        ${resp}=  Create Service with info   ${SERVICE1}   ${description}   ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}  ${status[0]}   ${btype}    ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Set Suite Variable  ${id1}  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}  notificationType=${notifytype[1]}  minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}

        ${resp}=   Billable  ${start3}
        # clear_service      ${resp}
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[1]}    ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}   ${status[0]}   ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Set Suite Variable  ${id2}  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${id2}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}   serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
        Verify Response  ${resp}  consumerNoteTitle=${consumerNoteTitle}  preInfoTitle=${preInfoTitle}  preInfoText=${preInfoText}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Create Service With info-6
        [Documentation]  Create  service for a valid provider in billable Domain without Prepayment amount
        ${resp}=   Billable  ${start3}
        # clear_service      ${resp}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[1]}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}   status=${status[0]}  bType=${btype}   
         

JD-TC-Create Service With info-7
        [Documentation]   create service in Non Billable Domain  and didn't inputs total amount and  prepayment amount
        ${description}=  FakerLibrary.sentence
        ${resp}=   Non Billable
        # clear_service   ${resp}
        # clear_service      ${resp}
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}  ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${EMPTY}  ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}   
       

JD-TC-Create Service With info-UH1
        [Documentation]  Create an already existing service (Same service type)
        ${resp}=   Billable  ${start1}
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre1}=   Random Int   min=10   max=50
        Set Suite Variable  ${min_pre1}
        ${Total1}=   Random Int   min=100   max=500
        Set Suite Variable  ${Total1}
        ${min_pre1}=  Convert To Number  ${min_pre1}  1
        ${Total1}=  Convert To Number  ${Total1}  1
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}   ${status[0]}    ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}  notificationType=${notifytype[1]}  minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}    bType=${btype}  isPrePayment=${bool[1]}
        
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}     ${service_duration[1]}  ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}   ${status[0]}    ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"        
 

JD-TC-Create Service With info-UH2
        [Documentation]  Create an already existing service (Different service type)
        ${resp}=   Billable  ${start1}
        # clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre1}=   Random Int   min=10   max=50
        Set Suite Variable  ${min_pre1}
        ${Total1}=   Random Int   min=100   max=500
        Set Suite Variable  ${Total1}
        ${min_pre1}=  Convert To Number  ${min_pre1}  1
        ${Total1}=  Convert To Number  ${Total1}  1
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}   ${status[0]}    ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}  notificationType=${notifytype[1]}  minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}    bType=${btype}  isPrePayment=${bool[1]}
        
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}   ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}   ${status[0]}    ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"        
 


JD-TC-Create Service With info-UH3
        [Documentation]    Create a service without login
        ${description}=  FakerLibrary.sentence
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}     ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}   ${status[0]}   ${btype}  ${bool[1]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Create Service With info-UH4
        [Documentation]   Create a service using consumer login
        ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${description}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${description}     ${service_duration[1]}   ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}   ${status[0]}   ${btype}  ${bool[1]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0   ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

    
JD-TC-Create Service With info-8
        [Documentation]    Checking Service Type in before and after taking checkin 
        ${multilocPro}=  MultiLocation Domain Providers   min=80   max=90
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[4]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[0]}

        
        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${multilocPro[4]}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${PUSERPH_id2}=  Evaluate  ${multilocPro[4]}+10101
        ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
        Set Suite Variable   ${ZOOM_Pid2}

        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable   ${virtualCallingModes}

        
        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE3}  ${description}   ${service_duration[0]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[0]}

        
        ${resp}=  Update Service with info   ${s_id1}  ${SERVICE3}  ${Description1}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 

        ${loc96}=  FakerLibrary.Word
        ${companySuffix}=  FakerLibrary.companySuffix
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${address}=  get_lat_long_add_pin
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${description}=  FakerLibrary.sentence
        ${snote}=  FakerLibrary.Word
        ${dis}=  FakerLibrary.Word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        ${eTime}=  add_timezone_time  ${tz}  3  00  
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Create Location  ${loc96}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid96}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid96}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=  AddCustomer  ${CUSERNAME9}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
        
        ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY}  hi  ${bool[1]}  ${cid}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Suite Variable  ${wid1}  ${wid[0]}
        sleep  02s
          
        ${resp}=  Update Service with info   ${s_id1}  ${SERVICE3}  ${Description1}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_WL}"



JD-TC-Create Service With info-9
        [Documentation]     Checking Service Type in before and after taking appointment
        # ${resp}=  Encrypted Provider Login  ${multilocPro[3]}  ${PASSWORD}
        # Should Be Equal As Strings  ${resp.status_code}  200
        ${domresp}=  Get BusinessDomainsConf
        Should Be Equal As Strings  ${domresp.status_code}  200

        ${dlen}=  Get Length  ${domresp.json()}
        FOR  ${pos}  IN RANGE  ${dlen}  
                Set Test Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

                ${subdomain}=  Get Billable Subdomain  ${domain}  ${domresp}  ${pos}  
                Set Test Variable   ${subdomain}
                Exit For Loop IF    '${subdomain}'

        END
        ${firstname}=  FakerLibrary.name
        ${lastname}=  FakerLibrary.last_name
        ${PUSERNAME_Y}=  Evaluate  ${PUSERNAME}+15309976     
        Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_Y}${\n}
        ${pkg_id}=   get_highest_license_pkg
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Y}   ${pkg_id[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${PUSERNAME_Y}  0
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${PUSERNAME_Y}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_Y}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${PUSERNAME_Y}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Y}  ${PASSWORD}
        Log  ${resp.json()}
      

        ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Test Variable   ${DAY}
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable    ${list}
        ${PUSERPH4}=  Evaluate  ${PUSERNAME[3]}+1505
        Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
        ${PUSERPH5}=  Evaluate  ${PUSERNAME}+1506
        Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
        ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
        ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
        ${bs}=  FakerLibrary.bs
        ${companySuffix}=  FakerLibrary.companySuffix
        # ${city}=   get_place
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        # ${sTime}=  db.get_time_by_timezone   ${tz}
        ${sTime}=  db.get_time_by_timezone  ${tz}
        ${eTime}=  add_timezone_time  ${tz}  0  15  
        ${desc}=   FakerLibrary.sentence
        ${url}=   FakerLibrary.url
        ${parking}   Random Element   ${parkingType}
        ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${fields.status_code}   200
        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${spec}=  get_Specializations  ${resp.json()}
        ${resp}=  Update Specialization  ${spec}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp}=  Enable Appointment
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   01s
    
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep   1s


        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${multilocPro[3]}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${PUSERPH_id2}=  Evaluate  ${multilocPro[3]}+10101
        ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
        Set Suite Variable   ${ZOOM_Pid2}

        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable   ${virtualCallingModes}

        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE3}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${ServiceType[0]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${ServiceType[0]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 
                                                                
        ${resp}=  Update Service with info   ${s_id1}   ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 

        ${loc97}=  FakerLibrary.Word
        ${companySuffix}=  FakerLibrary.companySuffix
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${address}=  get_lat_long_add_pin
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${description}=  FakerLibrary.sentence
        ${snote}=  FakerLibrary.Word
        ${dis}=  FakerLibrary.Word
        ${list}=  Create List  1  2  3  4  5  6  7
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        ${eTime}=  add_timezone_time  ${tz}  3  00  
        ${DAY}=  db.get_date_by_timezone  ${tz}
        ${resp}=  Create Location  ${loc97}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid97}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid97}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=   Get jaldeeIntegration Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

        ${DAY1}=  db.get_date_by_timezone  ${tz}
        Set Suite Variable  ${DAY1} 
        ${DAY2}=  db.add_timezone_date  ${tz}  10        
        Set Suite Variable  ${DAY2} 
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list} 
        ${sTime1}=  add_timezone_time  ${tz}  1  30  
        Set Suite Variable   ${sTime1}
        ${delta}=  FakerLibrary.Random Int  min=10  max=60
        Set Suite Variable  ${delta}
        ${eTime1}=  add_two   ${sTime1}  ${delta}
        Set Suite Variable   ${eTime1}
        ${schedule_name}=  FakerLibrary.bs
        Set Suite Variable  ${schedule_name}
        ${parallel}=  FakerLibrary.Random Int  min=1  max=10
        ${duration}=  FakerLibrary.Random Int  min=1  max=${delta}
        ${bool1}=  Random Element  ${bool}

        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid97}  ${duration}  ${bool1}   ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sch_id}  ${resp.json()}

        ${Addon_id}=  get_statusboard_addonId
        ${resp}=  Add addon  ${Addon_id}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200  

        ${order1}=   Random Int   min=0   max=1
        ${Values}=  FakerLibrary.Words  	nb=3
        ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
        Log  ${fieldList}
        Set Suite Variable   ${fieldList}
        ${service_list}=  Create list  ${s_id1}
        Set Suite Variable  ${service_list}  
        ${s_name}=  FakerLibrary.Words  nb=2
        ${s_desc}=  FakerLibrary.Sentence
        ${serr}=   Create Dictionary  id=${s_id1}
        ${ser}=  Create List   ${serr} 
    
     
        ${appt_sh}=   Create Dictionary  id=${sch_id}
        ${appt_shd}=    Create List   ${appt_sh}
        ${app_status}=    Create List   ${apptStatus[1]}
        ${resp}=   Create Appointment QueueSet for Provider    ${s_name[0]}   ${s_name[1]}   ${s_desc}   ${fieldList}       ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sba_id1}  ${resp.json()}

        ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
        Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

        ${resp}=  AddCustomer  ${CUSERNAME8}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}

        # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${cid}   ${resp.json()[0]['id']}

        ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
        ${apptfor}=   Create List  ${apptfor1}
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid1}  ${apptid[0]}

        ${resp}=  Get Bill By UUId  ${apptid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['uuid']}  ${apptid1}
        sleep  02s

        ${resp}=   Update Service with info   ${s_id1}  ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[0]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_APPT}"



JD-TC-Create Service With info-10
        [Documentation]   Checking Service Type  before and after adding in queue
        ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        
        ${resp}=  Create Service    ${SERVICE3}  ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME135}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${PUSERPH_id2}=  Evaluate  ${PUSERNAME135}+10101
        ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
        Set Suite Variable   ${ZOOM_Pid2}

        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable   ${virtualCallingModes}

        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE3}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${ServiceType[0]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${ServiceType[0]}

        ${resp}=  Update Service With Service Type   ${s_id1}   ${SERVICE3}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}   ${bool[0]}   ${serviceType[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200


        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}


        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lid121}  ${resp.json()[0]['id']}

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid121}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE3}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${ServiceType[0]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${ServiceType[0]}


JD-TC-Create Service With info-11
        [Documentation]   Create service for a branch in default department

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        ${resp}=  Get Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Enable Disable Department  ${toggle[1]}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END

        ${resp}=  Create Sample Service  ${SERVICE1}
        Set Suite Variable  ${sid1}  ${resp}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Enable Disable Department  ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}
        
        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30


        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info   ${SERVICE1}  ${desc}  ${ser_duratn}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}   ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}

        
JD-TC-Create Service With info-12
        [Documentation]   Create service for a branch in custom department

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service   ${PUSERNAME25}
        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${dep_name1}=  FakerLibrary.bs
        Set Suite Variable   ${dep_name1}
        ${dep_code1}=   Random Int  min=100   max=999
        Set Suite Variable   ${dep_code1}
        ${dep_desc1}=   FakerLibrary.word  
        Set Suite Variable    ${dep_desc1}
        ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${depid1}  ${resp.json()}

        @{empty_list}=  Create List

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Set Test Variable  ${depid1}    ${resp.json()['departments'][1]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}
        
        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}   ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}  serviceType=${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}


JD-TC-Create Service With info-13
        [Documentation]   Create service for a branch in default department & custom department
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        @{empty_list}=  Create List

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Set Test Variable  ${depid1}    ${resp.json()['departments'][1]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30


        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}  serviceType=${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service with info  ${SERVICE2}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${status[0]}   ${btype}    ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['departments'][0]['departmentId']}    ${def_depid} 
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}   ${sid2}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Should Be Equal As Strings   ${resp.json()['departments'][1]['departmentId']}     ${depid1} 
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}



JD-TC-Create Service With info-14
        [Documentation]   Create service for a branch in default department & custom department with same service name
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        @{empty_list}=  Create List

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Set Test Variable  ${depid1}    ${resp.json()['departments'][1]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30



        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['departments'][0]['departmentId']}    ${def_depid} 
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}   ${sid2}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Should Be Equal As Strings   ${resp.json()['departments'][1]['departmentId']}     ${depid1} 
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}



JD-TC-Create Service With info-15
        [Documentation]   Create multiple services for a branch in default department

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        @{empty_list}=  Create List

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}
        
        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service with info  ${SERVICE2}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}     ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid3}  ${resp.json()}

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid2}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}   ${sid3}



JD-TC-Create Service With info-16
        [Documentation]   Create multiple services for a branch in custom department 
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        @{empty_list}=  Create List

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Set Test Variable  ${depid1}    ${resp.json()['departments'][1]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}
        
        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30



        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service with info  ${SERVICE2}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}   ${sid2}



JD-TC-Create Service With info-17
        [Documentation]   Create same service for a branch in default department & custom department
        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        @{empty_list}=  Create List

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        Set Test Variable  ${depid1}    ${resp.json()['departments'][1]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}
        
        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        
        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}  ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}  ${ser_duratn}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${depid1}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}

        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid2}



JD-TC-Create Service With info-UH5
        [Documentation]   Create service with same name as existing service for a branch in default department

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        ${resp}=  Get Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[1]}
            ${resp}=  Enable Disable Department  ${toggle[1]}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END

        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        ${resp}=  Create Sample Service  ${SERVICE1}
        Set Suite Variable  ${sid1}  ${resp}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Enable Disable Department  ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}
        
        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}

        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}  ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}


JD-TC-Create Service With info-UH6
        [Documentation]   Create multiple services with same name for a branch in default department

        ${resp}=  Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        # clear_service   ${PUSERNAME25}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${empty_list}=   Create List

        ${resp}=  Get Departments 
        Log  ${resp.json()}
        Set Test Variable  ${def_depid}    ${resp.json()['departments'][0]['departmentId']}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds']}   ${empty_list}
        Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}
        
        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        
        ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service with info  ${SERVICE1}  ${desc}   ${ser_duratn}   ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${def_depid}   0    ${consumerNoteMandatory[0]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid2}




JD-TC-Create Service With info-18- consumer_Note_Mandatory
        [Documentation]    Enable  consumer note mandatory and create service
        ${multilocPro}=  MultiLocation Domain Providers   min=120   max=130
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id3}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id3} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}


JD-TC-Create Service With info-UH6- consumer_Note_Mandatory
        [Documentation]    Enable  consumer note mandatory and create service using consumer_note_title as EMPTY
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
       
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${EMPTY}   ${preInfoEnabled[0]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[0]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id25}    ${resp.json()} 
        Set Suite Variable  ${default_note}   Notes
        ${resp}=   Get Service By Id   ${s_id25} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${default_note}   preInfoEnabled=${bool[0]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[0]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}
       

JD-TC-Create Service With info-19-Pre_info
        [Documentation]    Enable pre_info status and try to set pre_info text as EMPTY
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${EMPTY}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id23}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id23} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${EMPTY}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${postInfoText}



JD-TC-Create Service With info-UH7-Pre_info
        [Documentation]    Enable pre_info status and try to set pre_info title as EMPTY
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${EMPTY}   ${EMPTY}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${postInfoText}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}    ${INVALID_SERVICE_PRE_INFO_TITLE}
        


JD-TC-Update Service With info-20-Post_info
        [Documentation]    Enable post_info status and try to set post_info text as EMPTY
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${postInfoTitle}   ${EMPTY}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id24}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id24} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${serviceType[1]}
        Verify Response  ${resp}  name=${SERVICE3}  description=${description}  serviceDuration=${ser_durtn}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}
        Verify Response  ${resp}  consumerNoteMandatory=${bool[1]}   consumerNoteTitle=${consumerNoteTitle}   preInfoEnabled=${bool[1]}   preInfoTitle=${preInfoTitle}   preInfoText=${preInfoText}   postInfoEnabled=${bool[1]}   postInfoTitle=${postInfoTitle}   postInfoText=${EMPTY}

        
        
JD-TC-Create Service With info-UH8-Post_info
        [Documentation]    Enable post_info status and try to set post_info title as EMPTY
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        # clear_service       ${multilocPro[0]}
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1

        ${consumerNoteTitle}=  FakerLibrary.sentence    
        ${preInfoTitle}=  FakerLibrary.sentence   
        ${preInfoText}=  FakerLibrary.sentence  
        ${postInfoTitle}=  FakerLibrary.sentence  
        ${postInfoText}=  FakerLibrary.sentence
        Log   ${virtualCallingModes}
        
        ${resp}=  Create Service with info    ${SERVICE3}  ${description}   ${ser_durtn}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}   ${status[0]}   ${btype}  ${bool[0]}  ${bool[0]}   ${serviceType[1]}   ${vstype}   ${virtualCallingModes}   ${EMPTY}   0    ${consumerNoteMandatory[1]}   ${consumerNoteTitle}   ${preInfoEnabled[1]}   ${preInfoTitle}   ${preInfoText}   ${postInfoEnabled[1]}   ${EMPTY}   ${EMPTY}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings   ${resp.json()}    ${INVALID_SERVICE_POST_INFO_TITLE}
        


*** Keywords ***
Billable
  [Arguments]  ${start}

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${start}   ${length}
            
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=   Get Active License
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=   Get Service
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Disable Services
        ${resp}=  Get Waitlist Settings
	${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   Disable Services
        Exit For Loop IF     '${check}' == 'True'

    END  




Non Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE  ${start1}    ${length}
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  Get Waitlist Settings
	${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Enable Disable Department  ${toggle[1]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'False'   Disable Services
        Exit For Loop IF     '${check}' == 'False'
       
     END 
     RETURN   ${PUSERNAME${a}}


Disable Services

        ${resp}=   Get Service  status-eq=ACTIVE
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}   IN RANGE   ${len}
                Set Test Variable   ${sid${i}}   ${resp.json()[${i}]['id']}
        END
        FOR   ${i}   IN RANGE   ${len}
                Log   ${sid${i}}
                # ${resp}=   Run Keyword And Return If  '${resp.json()[${i}]['status']}' == 'ACTIVE'    Disable service  ${sid${i}} 
                ${resp}=   Disable service  ${sid${i}}
        END
        ${resp}=   Get Service  status-eq=ACTIVE
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

  
	

