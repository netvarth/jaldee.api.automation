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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${SERVICE1}     SERVICE1
${SERVICE2}     SERVICE2
${SERVICE3}     SERVICE3
${SERVICE4}     SERVICE4
${SERVICE5}     SERVICE5
${SERVICE6}     SERVICE6
@{service_duration}  10  20  30   40   50


*** Test Cases ***

JD-TC-GetServices-1

    [Documentation]  Get  services for a valid provider
    ${description}=  FakerLibrary.sentence

    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    Set Suite Variable  ${Total}
    Set Suite Variable  ${min_pre}
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service       ${HLPUSERNAME7}  


    ${resp}=  Create Service  ${SERVICE1}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}     ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}    ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Set Suite Variable  ${id4}  ${resp.json()}
    ${resp}=  Disable service  ${id4}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Service  ${SERVICE5}    ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  notificationType=${notifytype[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id5}  ${resp.json()}
    ${resp}=  Disable service  ${id5}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5
    Verify Response List  ${resp}  0  name=${SERVICE5}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}   status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}
    Verify Response List  ${resp}  1  name=${SERVICE4}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}   bType=${btype}  status=${status[1]}  isPrePayment=${bool[1]}
    Verify Response List  ${resp}  2  name=${SERVICE3}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}   status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    Verify Response List  ${resp}  3  name=${SERVICE2}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}   bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]} 
    Verify Response List  ${resp}  4  name=${SERVICE1}  description=${description}  serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}   status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-2

    [Documentation]   Get  services for a valid provider filter by id
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id1}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE1}    serviceDuration=${service_duration[1]}     notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-3

    [Documentation]  Get  services for a valid provider filter by  name
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  name-eq=${SERVICE2}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  1
	Verify Response List  ${resp}  0  name=${SERVICE2}   serviceDuration=${service_duration[1]}    notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}	  

JD-TC-GetServices-4

    [Documentation]  Get  services for a valid provider filter by status ACTIVE
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  status-eq=ACTIVE 
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  3
	Verify Response List  ${resp}  0  name=${SERVICE3}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}	  
	Verify Response List  ${resp}  1  name=${SERVICE2}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}	  
	Verify Response List  ${resp}  2  name=${SERVICE1}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-5

    [Documentation]    Get  services for a valid provider filter by status INACTIVE
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  status-eq=INACTIVE 
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  2
    Verify Response List  ${resp}  1  name=${SERVICE4}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}	  	  
	Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}	  	  

JD-TC-GetServices-6


    [Documentation]   Get  services for a valid provider filter by account number
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${accNo}  ${decrypted_data['id']}
    
    ${resp}=   Get Service  account-eq=${accNo}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  5
    Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}	  
	Verify Response List  ${resp}  1  name=${SERVICE4}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}	  
	Verify Response List  ${resp}  2  name=${SERVICE3}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}	  
	Verify Response List  ${resp}  3  name=${SERVICE2}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}
    Verify Response List  ${resp}  4  name=${SERVICE1}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}


JD-TC-GetServices-7

    [Documentation]  Get  services for a valid provider filter by notification Type
    ${description}=  FakerLibrary.sentence
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Create Service  ${SERVICE6}  ${description}   {service_duration[1]}  ${bool[1]}  ${Total}  ${bool[1]}  minPrePaymentAmount=${min_pre}  notificationType=${notifytype[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id6}  ${resp.json()}
    ${resp}=   Get Service By Id  ${id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service   notificationType-eq=none 
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${count}=  Get Length  ${resp.json()} 
	Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE6}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[0]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}	  

JD-TC-GetServices-8

    [Documentation]  Get  services for a valid provider filter by notificationType ,account no and status
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service   account-eq=${accNo}  status-eq=INACTIVE  notificationType-eq=pushMsg
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
	Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  isPrePayment=${bool[1]}  bType=${btype}	  


JD-TC-GetServices-9

    [Documentation]  Get  services for a valid provider filter by service id ,account no,status and notificationType
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id1}   account-eq=${accNo}  status-eq=ACTIVE  notificationType-eq=${notifytype[2]}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE1}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]} 


JD-TC-GetServices-10


    [Documentation]  Get  services for a valid provider filter by service id ,account no
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id2}   account-eq=${accNo}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE2}   serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[0]}   bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-11

    [Documentation]  Get  services for a valid provider filter by service id ,status
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id4}   status-eq=INACTIVE
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE4}    serviceDuration=${service_duration[1]}    notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=${status[1]}  isPrePayment=${bool[1]}

JD-TC-GetServices-12

    [Documentation]  Get  services for a valid provider filter by service id ,notificationType
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id5}   notificationType-eq=pushMsg
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}   bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-13

    [Documentation]  Get  services for a valid provider filter by service id ,name
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  id-eq=${id5}   name-eq=${SERVICE5}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}    bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-14

    [Documentation]  Get  services for a valid provider filter by name and account
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  name-eq=${SERVICE5}  account-eq=${accNo}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE5}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[1]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=${status[1]}  bType=${btype}  isPrePayment=${bool[1]}

JD-TC-GetServices-15

    [Documentation]  Get  services for a valid provider filter by name and notificationType
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  name-eq=${SERVICE4}  notificationType-eq=${notifytype[2]}
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE4}    serviceDuration=${service_duration[1]}    notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=${status[1]}  isPrePayment=${bool[1]} 

JD-TC-GetServices-16

    [Documentation]  Get  services for a valid provider filter by name and status
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service  name-eq=${SERVICE4}  status-eq=INACTIVE
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  1
    Verify Response List  ${resp}  0  name=${SERVICE4}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=INACTIVE  isPrePayment=${bool[1]}  



JD-TC-GetServices-17

    [Documentation]  Get  services for a valid provider filter by account and notificationType
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service    account-eq=${accNo}  notificationType-eq=${notifytype[2]}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4
    Verify Response List  ${resp}  0  name=${SERVICE4}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=INACTIVE  isPrePayment=${bool[1]}  
    Verify Response List  ${resp}  1  name=${SERVICE3}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=ACTIVE  bType=${btype}  isPrePayment=${bool[1]} 
    Verify Response List  ${resp}  2  name=${SERVICE2}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=ACTIVE  isPrePayment=${bool[1]}  
    Verify Response List  ${resp}  3  name=${SERVICE1}    serviceDuration=${service_duration[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=ACTIVE  bType=${btype}  isPrePayment=${bool[1]} 

JD-TC-GetServices-18

    [Documentation]  Get  services for a valid provider filter by account and status
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service    account-eq=${accNo}  status-eq=ACTIVE
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  4
    Verify Response List  ${resp}  0  name=${SERVICE6}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[0]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=ACTIVE  bType=${btype}  isPrePayment=${bool[1]} 	  
    Verify Response List  ${resp}  1  name=${SERVICE3}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=ACTIVE  bType=${btype}  isPrePayment=${bool[1]} 
    Verify Response List  ${resp}  2  name=${SERVICE2}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}  minPrePaymentAmount=${min_pre}  totalAmount=${Total}  bType=${btype}  status=ACTIVE  isPrePayment=${bool[1]}  
    Verify Response List  ${resp}  3  name=${SERVICE1}    serviceDuration=${service_duration[1]}  notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre}  totalAmount=${Total}  status=ACTIVE  bType=${btype}  isPrePayment=${bool[1]} 
  

JD-TC-GetServices-19

    [Documentation]  Get  services for a valid provider filter by notificationType and status
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Get Service    notificationType-eq=pushMsg  status-eq=ACTIVE
    Should Be Equal As Strings  ${resp.status_code}  200   
	${count}=  Get Length  ${resp.json()} 
    Should Be Equal As Integers  ${count}  0


JD-TC-GetServices-UH1 

    [Documentation]  Get  services by login as consumer

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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

    ${resp}=    Send Otp For Login    ${consumerPhone}    ${accNo}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${consumerPhone}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}
   
    ${resp}=    ProviderConsumer Login with token    ${consumerPhone}    ${accNo}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get Service
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}    ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetServices-UH2

    [Documentation]  Get services without login
    ${resp}=   Get Service
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"