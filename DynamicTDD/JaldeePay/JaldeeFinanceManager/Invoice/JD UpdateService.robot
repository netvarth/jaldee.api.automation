*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{service_names}

${service_duration}     30
@{emptylist}
${DisplayName1}   item1_DisplayName






*** Test Cases ***

JD-TC-UpdateService-1

    [Documentation]  update service

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${userName}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}


    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

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
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${name}=   FakerLibrary.word
    ${resp}=  CreateVendorCategory  ${name}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id}   ${resp.json()}

    ${resp}=  Get by encId  ${category_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}          ${name}
    Should Be Equal As Strings  ${resp.json()['status']}        ${toggle[0]}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}



    ${resp1}=  AddCustomer  ${CUSERNAME39}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList} 

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${srv_duration}=   Random Int   min=10   max=20
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${srv_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}    department=${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 



    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${invoiceId}=   FakerLibrary.word

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1

        ${serviceprice}=   Random Int  min=1000  max=1500
    ${serviceprice}=  Convert To Number  ${serviceprice}  1


    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}   price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}      ${invoiceId}    ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 


    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE2}
    ${desc1}=   FakerLibrary.sentence
    ${servicecharge1}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${SERVICE2}  ${desc1}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[0]}    department=${dep_id}
    # ${resp}=  Create Service  ${SERVICE2}  ${desc1}   ${service_duration}   ${status[0]}    ${btype}    ${bool[1]}    ${notifytype[2]}   ${EMPTY}  ${servicecharge1}  ${bool[0]}  ${bool[0]}    department=${dep_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()} 

     ${quantity1}=   Random Int  min=5  max=10
    ${quantity1}=  Convert To Number  ${quantity1}  1


    ${serviceList1}=  Create Dictionary  serviceId=${sid2}   quantity=${quantity1}   price=${serviceprice}
    Set Suite Variable  ${serviceList1}  
    


     ${resp}=  Update Invoice Service  ${invoice_uid}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['serviceName']}  ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['serviceList'][1]['quantity']}  ${quantity1}


JD-TC-UpdateService-UH1

    [Documentation]  Update Item with invalid invoice id.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${invoice}=    FakerLibrary.word

     ${resp}=  Update Invoice Service  ${invoice}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-UpdateService-UH2

    [Documentation]  Update Item with empty service list.

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${invoice}=    FakerLibrary.word
    ${service}=  Create Dictionary  


     ${resp}=  Update Invoice Service  ${invoice_uid}   ${service}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${quantity_cannot_empty}

JD-TC-UpdateService-UH3
    [Documentation]   Update item Without login

     ${resp}=  Update Invoice Service  ${invoice_uid}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-UpdateService-UH4
    [Documentation]   Login as consumer and Update service

    ${pid}=  get_acc_id  ${HLPUSERNAME52}

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Generate random string    10    123456987
    ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    Set Suite Variable    ${primaryMobileNo}
    ${email}=    FakerLibrary.Email
    Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${pid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    # ${resp}=    Consumer Logout
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}    ${primaryMobileNo}     ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${pid}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable    ${cid1}    ${resp.json()['providerConsumer']}

     ${resp}=  Update Invoice Service  ${invoice_uid}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-UpdateService-UH5
    [Documentation]   A provider try to Update another providers service


    ${resp}=  Encrypted Provider Login  ${PUSERNAME201}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

     ${resp}=  Update Invoice Service  ${invoice_uid}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-UpdateService-UH6

    [Documentation]  update bill status as settled(we cant update status from draft to settled) then try to update service .

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME52}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${billStatusNote}=   FakerLibrary.word

    ${resp}=  Update bill status   ${invoice_uid}    ${billStatus[1]}    ${billStatusNote}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # ${INVOICE_SETTLED}=  format String   ${INVOICE_SETTLED}   ${billStatus[1]}

     ${resp}=  Update Invoice Service  ${invoice_uid}   ${serviceList1}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}   ${INVOICE_SETTLED}