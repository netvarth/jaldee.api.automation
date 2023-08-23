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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

#Suite Setup       Run Keyword    wlsettings
*** Variables ***
@{service_duration}  10  20  30   40   50
${SERVICE1}   S1SERVICE1 
${SERVICE10}   S1SERVICE10 
${start1}         20
${start2}         50
${start3}         80
${loc}          TGR 
${queue1}     QUEUE1
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}     0
@{provider_list}
@{dom_list}
@{multiloc_providers}
${SERVICE11}   S1SERVICE11
${SERVICE2}   S1SERVICE2
@{empty_list}
${zero_amt}   ${0.0}


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
#                 ${resp}=  View Waitlist Settings
#                 Log   ${resp.json()}
#                 Should Be Equal As Strings    ${resp.status_code}    200
#                 Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
#         END
#         [Return]  ${multiloc_providers}

*** Test Cases ***

JD-TC-CreateService-1
        [Documentation]   Create  service for a valid provider in Billable domain
        ${resp}=   Billable  ${start1}
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${min_pre}=   Random Int   min=10   max=50
        ${Total}=   Random Int   min=100   max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${Total}=  Convert To Number  ${Total}  1
        ${SERVICE1}=    FakerLibrary.word
        ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]} 
        

JD-TC-CreateService-2

        [Documentation]   Create  service in Non Billable domain
        ${resp}=   Non Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        # ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${EMPTY}  ${bool[0]}  ${bool[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[2]}   totalAmount=0.0   status=${status[0]}   bType=${btype}  isPrePayment=${bool[0]}   
       
JD-TC-CreateService-3

        [Documentation]     Create  a service for a valid provider with service name same as another provider
        
        ${description}=  FakerLibrary.sentence
        ${min_pre1}=   Random Int   min=1   max=10
        ${Total1}=   Random Int   min=100   max=500
        ${min_pre1}=  Convert To Number  ${min_pre1}  1
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=   Billable  ${start2}
        clear_service      ${resp}
        #${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        #${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
        ${resp}=  Create Service   ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        ${resp}=   Get Service By Id  ${resp.json()}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}   notification=${bool[1]}  notificationType=${notifytype[1]}  minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}
        ${resp}=   Billable  ${start3}
        clear_service      ${resp}
        ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
        Log  ${resp.json()}
        Set Suite Variable  ${id1}  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}   serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-CreateService-4

        [Documentation]  Create  service for a valid provider in billable Domain without Prepayment amount
        ${resp}=   Billable  ${start1}
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[1]}  ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   totalAmount=${Total1}   status=${status[0]}  bType=${btype}  
        Dictionary Should Not Contain Key  ${resp.json()}  minPrePaymentAmount 
         
JD-TC-CreateService-5

        [Documentation]   create service in Non Billable Domain  and didn't inputs total amount and  prepayment amount
        ${description}=  FakerLibrary.sentence
        ${resp}=   Non Billable
        clear_service   ${resp}
        clear_service      ${resp}
        ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[1]}  ${status[0]}   ${btype}   ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${EMPTY}  ${bool[0]}  ${bool[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}  notificationType=${notifytype[1]}  totalAmount=0.0  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]}   
       
JD-TC-CreateService-UH1
        
        [Documentation]  Create an already existing service
        ${description}=  FakerLibrary.sentence
        #  clear_service       ${PUSERNAME35}
        ${resp}=   Billable  ${start1}
        clear_service      ${resp}
        ${min_pre1}=   Random Int   min=10   max=50
        Set Suite Variable  ${min_pre1}
        ${Total1}=   Random Int   min=100   max=500
        Set Suite Variable  ${Total1}
        ${min_pre1}=  Convert To Number  ${min_pre1}  1
        ${Total1}=  Convert To Number  ${Total1}  1
        #  ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
        #  Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}    ${notifytype[1]}  ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notification=${bool[1]}  notificationType=${notifytype[1]}  minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}    bType=${btype}  isPrePayment=${bool[1]}
        ${resp}=  Create Service  ${SERVICE1}  ${description}     ${service_duration[1]}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"        
 
JD-TC-CreateService-UH2

        [Documentation]    Create a service without login
        ${description}=  FakerLibrary.sentence
        # ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        # ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
        ${resp}=  Create Service  ${SERVICE1}  ${description}     ${service_duration[1]}   ${status[0]}     ${btype}   ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}  ${bool[1]}  ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  419
        Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-CreateService-UH3

       
        [Documentation]   Create a service using consumer login
        ${description}=  FakerLibrary.sentence
        # ${min_pre1}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        # ${Total1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
        ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Create Service  ${SERVICE1}  ${description}     ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  401
        Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}



JD-TC-CreateService-6

        [Documentation]    Checking Service Type in before and after taking checkin 
        ${multilocPro}=  MultiLocation Domain Providers   min=85   max=95
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=  Create Service With serviceType    ${SERVICE10}  ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}   ${service_type[2]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        # ${resp}=  Enable Disable Virtual Service  Enable
        # Log  ${resp.json()}
        #  Should Be Equal As Strings  ${resp.status_code}  200

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${multilocPro[0]}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${PUSERPH_id2}=  Evaluate  ${multilocPro[0]}+10101
        ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
        Set Suite Variable   ${ZOOM_Pid2}

        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable   ${virtualCallingModes}

        
        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[1]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 
     
        ${resp}=   Update Service With Service Type   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[2]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 


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
        ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid1}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${s_id1}
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
              
        ${resp}=   Update Virtual Service   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_WL}"

JD-TC-CreateService-7

        [Documentation]     Checking Service Type in before and after taking appointment
        # ${resp}=  Encrypted Provider Login  ${multilocPro[1]}  ${PASSWORD}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # ${resp}=   Billable
        # # clear_location  ${PUSERNAME_PH}
        # # clear_customer   ${PUSERNAME_PH}
        # ${GST_num}    ${pan_num}=  db.Generate_gst_number  ${Container_id}
        # Log   ${GST_num}
        # ${resp}=  Update Tax Percentage  18   ${GST_num} 
        # Should Be Equal As Strings    ${resp.status_code}   200
        # ${resp}=  Enable Tax
        # Should Be Equal As Strings    ${resp.status_code}   200
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
        ${PUSERNAME_Y}=  Evaluate  ${PUSERNAME}+1530      
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_Y}${\n}
        ${pkg_id}=   get_highest_license_pkg
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Y}   ${pkg_id[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${PUSERNAME_Y}  0
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${PUSERNAME_Y}  ${PASSWORD}  0
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${PUSERNAME_Y}
        ${resp}=  Encrypted Provider Login  ${PUSERNAME_Y}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${DAY}=  db.get_date_by_timezone  ${tz}
        Set Test Variable   ${DAY}
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable    ${list}
        ${PUSERPH4}=  Evaluate  ${multilocPro[1]}+1505
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH4}${\n}
        ${PUSERPH5}=  Evaluate  ${PUSERNAME}+1506
        Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERPH5}${\n}
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
        ${resp}=  Create Service With serviceType    ${SERVICE10}  ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}   ${service_type[2]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 

        ${resp}=  Update Service With Service Type   ${s_id1}   ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}   ${bool[0]}   ${service_type[2]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        ${resp}=   Get Service
        Should Be Equal As Strings  ${resp.status_code}  200 

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
        ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid1}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${s_id1}
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
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid1}  ${duration}  ${bool1}   ${s_id1}
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
        ${app_status}=    Create List   ${apptStatus[2]}
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

        ${resp}=   Update Virtual Service   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICETYPE_CAN_NOT_CHANGE_USED_IN_APPT}"


JD-TC-CreateService-8

        [Documentation]   Checking Service Type  before and after adding in queue
        ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=  Create Service With serviceType    ${SERVICE10}  ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}   ${service_type[2]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${PUSERNAME135}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   status=ACTIVE    instructions=${instructions2} 
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

        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[1]}

        ${resp}=  Update Service With Service Type   ${s_id1}   ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}   ${bool[0]}   ${service_type[2]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

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
        ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid1}  ${resp.json()} 

        ${capacity}=   Random Int   min=20   max=100
        ${parallel}=   Random Int   min=1   max=2
        ${sTime}=  add_timezone_time  ${tz}  0  30  
        ${eTime}=  add_timezone_time  ${tz}  0  60  
        ${list}=  Create List  1  2  3  4  5  6  7
        ${DAY}=  db.get_date_by_timezone  ${tz}   
        Set Suite Variable  ${DAY}

        ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid1}  ${s_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${qid1}  ${resp.json()}

        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE10}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[1]}


JD-TC-CreateService-9
        [Documentation]   Create service for a branch in default department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

        ${resp}=  View Waitlist Settings
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp1}=   Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${resp}=  Create Sample Service  ${SERVICE1}
        Set Suite Variable  ${sid1}  ${resp}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Toggle Department Enable
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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}

        

JD-TC-CreateService-10
        [Documentation]   Create service for a branch in custom department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}


JD-TC-CreateService-11
        [Documentation]   Create service for a branch in default department & custom department
        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${SERVICE2}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
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


JD-TC-CreateService-12
        [Documentation]   Create multiple services for a branch in default department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${SERVICE2}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid3}  ${resp.json()}

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid2}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}   ${sid3}

JD-TC-CreateService-13
        [Documentation]   Create multiple services for a branch in custom department 
        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

        
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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${SERVICE2}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE2}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE2}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${resp}=  Get Department ById  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${depid1}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}   ${sid2}


JD-TC-CreateService-UH4
        [Documentation]   Create service with same name as existing service for a branch in default department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

        ${resp}=  View Waitlist Settings
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp1}=   Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable
        Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

        ${SERVICE1}=    FakerLibrary.word
        ${resp}=  Create Sample Service  ${SERVICE1}
        Set Suite Variable  ${sid1}  ${resp}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Toggle Department Enable
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
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid1}


JD-TC-CreateService-UH5
        [Documentation]   Create multiple services with same name for a branch in default department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

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
        
        ${SERVICE1}=    FakerLibrary.word
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid2}  ${resp.json()}

        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  422
        Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_CANT_BE_SAME}"

        ${resp}=  Get Department ById  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}    departmentId=${def_depid}   departmentStatus=${status[0]}
        Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}   ${sid2}


JD-TC-CreateService-UH6

        [Documentation]   Create service in the  billabe domain without prepayment amount and total amount 
        ${resp}=   Non Billable
        clear_service      ${resp}
        ${description}=  FakerLibrary.sentence
        ${resp}=   Create Service   ${SERVICE1}   ${description}     ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}    ${notifytype[1]}   ${min_pre1}  ${EMPTY}  ${bool[1]}   ${bool[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
     

JD-TC-CreateService-14

        [Documentation]    change    physicalService  to virtualService  
        ${multilocPro}=  MultiLocation Domain Providers   min=85   max=95
        Log  ${multilocPro}
        Set Suite Variable   ${multilocPro}
        ${len}=  Get Length  ${multilocPro}
        ${resp}=  Encrypted Provider Login  ${multilocPro[0]}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${ser_durtn}=   Random Int   min=2   max=10
        ${description}=  FakerLibrary.sentence
        ${Total1}=   Random Int   min=100   max=500
        ${Total1}=  Convert To Number  ${Total1}  1
        ${resp}=  Create Service With serviceType    ${SERVICE11}  ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[1]}  ${EMPTY}  ${Total1}  ${bool[0]}  ${bool[0]}   ${service_type[2]}
        Should Be Equal As Strings  ${resp.status_code}  200  
        Set Suite Variable    ${s_id1}    ${resp.json()} 
        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[2]}

        ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${multilocPro[0]}
        Set Suite Variable   ${ZOOM_id0}

        ${instructions1}=   FakerLibrary.sentence
        ${instructions2}=   FakerLibrary.sentence

        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
        ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME134}   status=ACTIVE    instructions=${instructions2} 
        ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

        ${resp}=  Update Virtual Calling Mode   ${vcm1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${PUSERPH_id2}=  Evaluate  ${multilocPro[0]}+10101
        ${ZOOM_Pid2}=  Format String  ${ZOOM_url}  ${PUSERPH_id2}
        Set Suite Variable   ${ZOOM_Pid2}

        Set Test Variable  ${callingMode1}     ${CallingModes[0]}
        Set Test Variable  ${ModeId1}          ${ZOOM_Pid2}
        Set Test Variable  ${ModeStatus1}      ACTIVE
        ${Description1}=    FakerLibrary.sentence
        ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
        ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}
        Set Suite Variable   ${virtualCallingModes}

        
        ${resp}=  Update Virtual Service   ${s_id1}  ${SERVICE11}  ${description}   ${service_duration[1]}   ${status[0]}    ${btype}   ${bool[1]}  ${notifytype[1]}  ${EMPTY}  ${Total1}    ${bool[0]}  ${bool[0]}   ${service_type[1]}   ${virtualCallingModes}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=   Get Service By Id   ${s_id1} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings   ${resp.json()['serviceType']}   ${service_type[1]}

JD-TC-CreateService-15

        [Documentation]    create service with tax enable 
        ${resp}=   Encrypted Provider Login     ${PUSERNAME88}   ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Account Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${description}=  FakerLibrary.sentence
        # ${time}=  FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
        ${resp}=  Create Service  ${SERVICE2}   ${description}  ${service_duration[1]}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  300.0  ${bool[0]}  ${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=   Get Service By Id  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[1]}    notification=${bool[1]}  notificationType=${notifytype[2]}   totalAmount=300.0   status=${status[0]}   bType=${btype}  isPrePayment=${bool[0]}   

JD-TC-CreateService-UH7

        [Documentation]   Create service for a branch in default department & custom department with same service name
        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

        
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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  ${resp.json()}   ${SERVICE_CANT_BE_SAME}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Suite Variable  ${sid2}  ${resp.json()}

        # ${resp}=  Get Departments 
        # Log  ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings   ${resp.json()['departments'][0]['departmentId']}    ${def_depid} 
        # Should Be Equal As Strings  ${resp.json()['departments'][0]['departmentStatus']}   ${status[0]}
        # Should Be Equal As Strings  ${resp.json()['departments'][0]['serviceIds'][0]}   ${sid2}
        # Should Be Equal As Strings  ${resp.json()['departments'][0]['isDefault']}   ${bool[1]}

        # Should Be Equal As Strings   ${resp.json()['departments'][1]['departmentId']}     ${depid1} 
        # Should Be Equal As Strings  ${resp.json()['departments'][1]['departmentStatus']}   ${status[0]}
        # Should Be Equal As Strings  ${resp.json()['departments'][1]['serviceIds'][0]}   ${sid1}
        # Should Be Equal As Strings  ${resp.json()['departments'][1]['isDefault']}   ${bool[0]}

JD-TC-CreateService-UH8

        [Documentation]   Create same service for a branch in default department & custom department
        ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${MUSERNAME27}

        
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

        ${SERVICE1}=    FakerLibrary.word
        Set Suite Variable  ${SERVICE1}
        ${desc}=   FakerLibrary.sentence
        ${servicecharge}=   Random Int  min=100  max=500
        ${ser_duratn}=      Random Int   min=10   max=30
        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${def_depid}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${sid1}  ${resp.json()}

        ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${depid1}
        Should Be Equal As Strings  ${resp.status_code}  422 
        Should Be Equal As Strings  ${resp.json()}   ${SERVICE_CANT_BE_SAME}


JD-TC-CreateService-16 

        [Documentation]   Create service with lead time. 
        ...  (preparation time for provider before next booking. when trying to make a booking in less than 10 mins of start of next slot, when lead time is 10 mins
        ...  the next slot will not be shown. there should be a time difference of 10 mins from current booking time to next slot.)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        
        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${leadTime}=   Random Int   min=1   max=5
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  leadTime=${leadTime}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  leadTime=${leadTime}


JD-TC-CreateService-17 

        [Documentation]   Create service with max bookings allowed. (one consumer can make as many bookings as specified in max bookings allowed)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        
        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${maxbookings}=   Random Int   min=1   max=10
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  maxBookingsAllowed=${maxbookings}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  maxBookingsAllowed=${maxbookings}


JD-TC-CreateService-18 

        [Documentation]   Create service with resoucesRequired. 
        # resoucesRequired defines how many resources we need to complete the said service, eg: say we have 4 resources- 4 beauticians
        # and we need 2 beauticians 1 for hair styling and the other as henna artist for one service, then the we give resource required for that service as 2.
        # In which case if parallelServing is set as 4 in a queue/schedule, noOfAvailbleSlots will only be 2, since we need 2 resources per service.
        # In a queue/Schedule parallelServing cannot be set as less than resoucesRequired.

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${resoucesRequired}=   Random Int   min=1   max=10
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  resoucesRequired=${resoucesRequired}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  resoucesRequired=${resoucesRequired}


JD-TC-CreateService-19 

        [Documentation]   Create service with priceDynamic.(allows to set schedule level price rather than service charge)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  priceDynamic=${bool[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  priceDynamic=${bool[1]}


JD-TC-CreateService-UH9 

        [Documentation]   Create Service with maxBookingsAllowed as empty

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        # ${maxbookings}=   Random Int   min=1   max=10
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  maxBookingsAllowed=${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  # maxBookingsAllowed=${maxbookings}


JD-TC-CreateService-UH10 

        [Documentation]   Create Service with resoucesRequired as empty

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        # ${resoucesRequired}=   Random Int   min=1   max=10
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  resoucesRequired=${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  #resoucesRequired=${resoucesRequired}


JD-TC-CreateService-UH11 

        [Documentation]   Create Service with leadTime as empty

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Random Int   min=1   max=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        # ${leadTime}=   Random Int   min=1   max=10
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  leadTime=${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  #resoucesRequired=${resoucesRequired}

# *** COMMENT ***
JD-TC-CreateService-20 

        [Documentation]   Create Service for a user

        ${resp}=  Encrypted Provider Login  ${MUSERNAME10}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp2}=   Get Business Profile
        Log  ${resp2.json()}
        Should Be Equal As Strings    ${resp2.status_code}    200
        Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

        # clear_service    ${MUSERNAME10}

        ${resp}=  View Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[0]}
                ${resp1}=  Toggle Department Enable
                Log   ${resp1.json()}
                Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=    Get Locations
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

        sleep  02s

        # ${resp}=  Get Departments
        # Log   ${resp.json()}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        ${resp}=  Get Departments
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
                ${dep_name1}=  FakerLibrary.bs
                ${dep_code1}=   Random Int  min=100   max=999
                ${dep_desc1}=   FakerLibrary.word  
                ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
                Log  ${resp1.content}
                Should Be Equal As Strings  ${resp1.status_code}  200
                Set Test Variable  ${dep_id}  ${resp1.json()}
        ELSE
                Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
        END

        ${u_id1}=  Create Sample User
        Set Test Variable  ${u_id1}

        ${resp}=  Get User By Id  ${u_id1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${MUSERNAME4_U1}  ${resp.json()['mobileNo']}

        ${resp}=  SendProviderResetMail   ${MUSERNAME4_U1}
        Should Be Equal As Strings  ${resp.status_code}  200

        @{resp}=  ResetProviderPassword  ${MUSERNAME4_U1}  ${PASSWORD}  2
        Should Be Equal As Strings  ${resp[0].status_code}  200
        Should Be Equal As Strings  ${resp[1].status_code}  200
        
        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Random Int  min=100  max=500
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${dep_id}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}



JD-TC-CreateService-21 

        [Documentation]   Create multiple Services for a user

        clear_service    ${MUSERNAME10}
        
        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Random Int  min=100  max=500
        # ${min_pre}=  Convert To Number  ${min_pre}  1
        ${servicecharge}=  Convert To Number  ${servicecharge}  1
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${dep_id}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}

        ${SERVICE2}=    FakerLibrary.Word
        ${desc2}=   FakerLibrary.sentence
        ${min_pre2}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        # ${servicecharge2}=   Random Int  min=100  max=500
        ${servicecharge2}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration2}=   Random Int   min=10   max=20
        ${resp}=  Create Service For User  ${SERVICE2}  ${desc2}   ${srv_duration2}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${servicecharge2}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${s_id2}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id2}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE2}  description=${desc2}  serviceDuration=${srv_duration2}  totalAmount=${servicecharge2}  status=${status[0]}  isPrePayment=${bool[0]}



JD-TC-CreateService-UH12 

        [Documentation]   Create Service for an invalid user id

        clear_service    ${MUSERNAME10}

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${inv_userid}    FakerLibrary.Random Number   digits=10  fix_len=True
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${dep_id}   provider=${inv_userid}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    422
        Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_TO_CREATE_SERVICE}



JD-TC-CreateService-UH13 

        [Documentation]   Create Service for a user from another account 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  ProviderLogout   
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Encrypted Provider Login  ${MUSERNAME5}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  View Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[0]}
                ${resp1}=  Toggle Department Enable
                Log   ${resp1.json()}
                Should Be Equal As Strings  ${resp1.status_code}  200
        END

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${dep_id}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    422
        Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION}



JD-TC-CreateService-UH14 

        [Documentation]   Create Service for an invalid department id 

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${inv_depid}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    404
        Should Be Equal As Strings    ${resp.json()}    ${INVALID_DEPARTMENT}


JD-TC-CreateService-UH15 

        [Documentation]   Create Service with department id as empty

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        # ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${EMPTY}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    422
        Should Be Equal As Strings    ${resp.json()}    ${DEPT_ID}


JD-TC-CreateService-UH16 

        [Documentation]   Create Service with user id as empty

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        # ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  department=${dep_id}   provider=${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    422
        Should Be Equal As Strings    ${resp.json()}    ${NO_PERMISSION_TO_CREATE_SERVICE}


JD-TC-CreateService-UH17 

        [Documentation]   Create Service for user without department

        ${resp}=  Encrypted Provider Login  ${MUSERNAME4_U1}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${u_id1}  ${decrypted_data['id']}

        # Set Test Variable  ${u_id1}  ${resp.json()['id']}

        ${resp}=  Get Departments
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}

        ${SERVICE1}=    FakerLibrary.Word
        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        # ${inv_depid}    FakerLibrary.Random Number   digits=10  fix_len=True
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}   provider=${u_id1}
        Log  ${resp.json()}
        Should Be Equal As Strings     ${resp.status_code}    422
        Should Be Equal As Strings    ${resp.json()}    ${DEPT_ID}


JD-TC-CreateService-22 

        [Documentation]   Create service with supportInternationalConsumer as true and set internationalAmount with prepayment. (service charge for international consumers)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[1]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-23 

        [Documentation]   Create service with supportInternationalConsumer as true and set internationalAmount without prepayment. (service charge for international consumers)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-24 

        [Documentation]   Create service with supportInternationalConsumer as true but without internationalAmount. (service charge for international consumers)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${zero_amt}



JD-TC-CreateService-25 

        [Documentation]   Create service with supportInternationalConsumer as false but with internationalAmount. (cannot set internationalAmount when supportInternationalConsumer is false)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  supportInternationalConsumer=${bool[0]}  internationalAmount=${intlamt}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[0]}  internationalAmount=${zero_amt}


JD-TC-CreateService-26 

        [Documentation]   Create service with supportInternationalConsumer as true but with internationalAmount as empty. (service charge for international consumers)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${zero_amt}



JD-TC-CreateService-27 

        [Documentation]   Create service with supportInternationalConsumer as true but with internationalAmount as less than service charge. (service charge for international consumers)

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${intlamt}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${servicecharge}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}

        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}   totalAmount=${servicecharge}  status=${status[0]}  isPrePayment=${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-28 

        [Documentation]   Create service with supportInternationalConsumer and prePaymentType as percentage

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre}  ${servicecharge}  ${bool[1]}  ${bool[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}  prePaymentType=${advancepaymenttype[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}


        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre}  totalAmount=${servicecharge}  status=${status[0]}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}


JD-TC-CreateService-29 

        [Documentation]   Create service with prePaymentType as percentage and prepayment set as a percentage value

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        ${min_pre_percent}=   Pyfloat  right_digits=1  min_value=10  max_value=50
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre_percent}  ${servicecharge}  ${bool[1]}  ${bool[0]}  prePaymentType=${advancepaymenttype[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}


        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre_percent}  totalAmount=${servicecharge}  status=${status[0]}  


JD-TC-CreateService-30 

        [Documentation]   Create service with prePaymentType as percentage and prepayment set as 100 percentage value

        ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200

        clear_service   ${PUSERNAME27}

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${desc}=   FakerLibrary.sentence
        # ${min_pre}=   Pyfloat  right_digits=1  min_value=100  max_value=100
        ${min_pre_percent}=   Convert To Number  100  1
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
        ${srv_duration}=   Random Int   min=10   max=20
        ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}   ${status[0]}  ${btype}   ${bool[1]}  ${notifytype[2]}   ${min_pre_percent}  ${servicecharge}  ${bool[1]}  ${bool[0]}  prePaymentType=${advancepaymenttype[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}   200
        Set Test Variable  ${s_id}  ${resp.json()}


        ${resp}=   Get Service By Id  ${s_id}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  name=${SERVICE1}  description=${desc}  serviceDuration=${srv_duration}  isPrePayment=${bool[1]}  minPrePaymentAmount=${min_pre_percent}  totalAmount=${servicecharge}  status=${status[0]}  





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
        ${resp}=  View Waitlist Settings
	Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'True'   Disable Services
        Exit For Loop IF     '${check}' == 'True'

    END   

Non Billable

    ${resp}=   Get File    /ebs/TDD/varfiles/musers.py
        ${len}=   Split to lines  ${resp}
        ${length}=  Get Length   ${len}

     FOR    ${a}   IN RANGE  ${start1}    ${length}
        # clear_service       ${PUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        ${resp}=  View Waitlist Settings
	Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
        ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Suite Variable  ${check}    ${resp2.json()['serviceBillable']} 
        Run Keyword IF   '${check}' == 'False'   Disable Services
        Exit For Loop IF     '${check}' == 'False'
       
     END 
     [Return]   ${MUSERNAME${a}}


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


# *** Keywords ***
wlsettings
        ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
        Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  View Waitlist Settings
        Should Be Equal As Strings  ${resp.status_code}  200

	Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
	${resp}=  ProviderLogout   
        Should Be Equal As Strings  ${resp.status_code}  200

	




# *** Commit ***


# #         [Documentation]    create service in Non billable domain  and  inputs total amount and  prepayment amount
        
# #         ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
# #         ${len}=   Split to lines  ${resp}
# #         ${length}=  Get Length   ${len}

# #      FOR    ${a}   IN RANGE    ${length}
# #         clear_service       ${PUSERNAME${a}}
# #         ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
# #         Should Be Equal As Strings    ${resp.status_code}    200
# #         ${domain}=   Set Variable    ${resp.json()['sector']}
# #         ${subdomain}=    Set Variable      ${resp.json()['subSector']}
# #         ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
# #         Should Be Equal As Strings    ${resp.status_code}    200
# #         ${check}=   Run Keyword If   '${resp2.json()['serviceBillable']}' == 'False'   nonbillablewithtotalamtandpre 
# #         Exit For Loop IF     '${check}' == 'False'
       
# #      END   
#      # want to update from backend....      



#  billableprepymntnotgiveamt
#        ${description}=  FakerLibrary.sentence
#        ${notifytype}    Random Element     ['none','pushMsg','email']
#        ${notify}    Random Element     ['True','False']
#        ${resp}=  Create Service  ${SERVICE1}  ${description}   30   ACTIVE   ${btype}   ${notify}  ${notifytype}   ${EMPTY}   500   True   False
#        Should Be Equal As Strings  ${resp.status_code}  422
#        Should Be Equal As Strings  "${resp.json()}"  "minimum pre payment should be entered and it should be equal to or higher than one"
#        [Return]   True