*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py


*** Variables ***

${self}     0
@{service_names}
${var_file}      ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}     ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
# ${LoginId}       ${PUSERNAME2}
# ${PASSWORD}      Jaldee12

# ${LoginId}       5554343565
# ${PASSWORD}      Pooja$health3

${LoginId}       5557411478
${PASSWORD}      Jaldee01

${loop_count}   200
# ${loop_count}   1
${maxBookings}  200
${max_days}   30

*** KEYWORDS ***
Get Random Slot
    [Arguments]    ${scheduleId}   ${date}   ${service}
    ${resp}=  Get Appointment Slots By Date Schedule  ${scheduleId}  ${date}  ${service}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    Log  ${slots}
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}
    RETURN  ${slot1}

*** Test Cases ***

JD-TC-Appointment-1

    [Documentation]  appt data generation

    ${resp}=  Encrypted Provider Login  ${LoginId}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}

    # ${decrypted_data}=  db.decrypt_data   ${resp.content}
    # Log  ${decrypted_data}
    # Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pdrname}  ${decrypted_data['userName']}


    ${resp}=    Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${service}    IN    @{resp.json()}
        # Registration service
        Run Keyword If    '${service['id']}' == '43482'    Set Test Variable    ${s_id1}    ${service['id']}
        Run Keyword If    '${service['id']}' == '43483'    Set Test Variable    ${s_id2}    ${service['id']}
        Run Keyword If    '${service['id']}' == '43484'    Set Test Variable    ${s_id3}    ${service['id']}
    END
        # IF    '${service['serviceCategory']}' == 'MainService' and ${service['totalAmount']} > 0 and 'provider' not in ${service} and '${service['status']}' == 'ACTIVE'
        #     Log    ${service['name']}
        #     ${s_id1}=    Get Variable Value    ${s_id1}    NONE
        #     IF    '${s_id1}' == 'NONE'
        #         Set Test Variable    ${s_id1}    ${service['id']}
        #     END
        # # Appointment service
        # ELSE IF    '${service['serviceCategory']}' == 'MainService' and ${service['totalAmount']} == 0 and 'provider' not in ${service} and '${service['status']}' == 'ACTIVE'
        #     Log    ${service['name']}
        #     ${s_id2}=    Get Variable Value    ${s_id2}    NONE
        #     IF    '${s_id2}' == 'NONE'
        #         Set Test Variable    ${s_id2}    ${service['id']}
        #     END
        # # SubService
        # ELSE IF    '${service['serviceCategory']}' == 'SubService' and '${service['status']}' == 'ACTIVE'
        #     Log    ${service['name']}
        #     ${s_id3}=    Get Variable Value    ${s_id3}    NONE
        #     IF    '${s_id3}' == 'NONE'
        #         Set Test Variable    ${s_id3}    ${service['id']}
        #     END
        # END
    # END

    Log Many  ${s_id1}  ${s_id2}  ${s_id3}

    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${desc1}=   FakerLibrary.sentence
    IF  ${resp.json()['maxBookingsAllowed']} <= 1
        ${resp}=  Update Service  ${s_id2}  ${resp.json()['name']}  ${resp.json()['description']}  ${resp.json()['serviceDuration']}  ${resp.json()['isPrePayment']}  ${resp.json()['totalAmount']}  maxBookingsAllowed=${maxBookings}   department=${resp.json()['department']}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    FOR    ${schedule}    IN    @{resp.json()}
        FOR  ${sch_srv}  IN  @{schedule['services']}
            IF  ${sch_srv['id']} == ${s_id2}
                Log    ${schedule['name']}
                Set Test Variable  ${sch_id}  ${schedule['id']}
                Set Test Variable  ${lid}  ${schedule['location']['id']}
                Set Test Variable  ${tz}  ${schedule['apptSchedule']['timezone']}
            END
        END
    END

    Log  ${sch_id}

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{user_list}=  Create List
    FOR    ${user}    IN    @{resp.json()}
        IF  ${user['id']} != ${provider_id}
            Append To List   ${user_list}  ${user['id']}
        END
    END

    Log  ${user_list}

    ${resp}=   Get Category With Filter  categoryType-eq=${categoryType[3]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${category_id}  ${resp.json()[0]['id']}
*** Comments ***
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${discountprice}=     Pyfloat  right_digits=1  min_value=50  max_value=100
    ${discount_name}=     Set Variable  Rs ${discountprice} Off
    ${desc}=   FakerLibrary.word
    ${resp}=   Create Discount  ${discount_name}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${discountId}   ${resp.json()}

    ${resp}=   Get Discounts 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    #------------------FOR LOOP Starts Here ---------------------------------------

    FOR   ${i}  IN RANGE   ${loop_count}
        ${CUSERPH}=    Generate Random 555 Number
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH}
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}  
        Log  ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200
        IF   '${resp.content}' == '${emptylist}'
            ${firstname}=  FakerLibrary.name
            ${lastname}=  FakerLibrary.last_name
            ${resp1}=  AddCustomer  ${CUSERPH${i}}   firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}
            Log  ${resp1.content}
            Should Be Equal As Strings  ${resp1.status_code}  200
            Set Test Variable  ${cid${i}}  ${resp1.json()}
        ELSE
            Set Suite Variable  ${cid${i}}  ${resp.json()[0]['id']}
            Set Suite Variable  ${firstname}  ${resp.json()[0]['firstName']}
        END

        #------------------------------------ First Appointment- walking without payment -------------------------------------------

        ${slot}=  Get Random Slot  ${sch_id}  ${DAY1}  ${s_id2}

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        ${quantity}=   Random Int  min=1  max=10
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}
        # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
        ${invoiceId}=  FakerLibrary.iana_id
        
        ${resp}=  Create Invoice   ${category_id}  ${DAY1}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid1}   ${resp.json()['uidList'][0]}  

        ${resp}=  Get Invoice By Id  ${invoice_uid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        #------------------------------------ 2nd Appointment- walking with cash payment ------------------------------------.......

        ${slot}=  Get Random Slot  ${sch_id}  ${DAY1}  ${s_id2}

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        ${quantity}=   Random Int  min=1  max=10
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}
        # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
        ${invoiceId}=  FakerLibrary.iana_id

        ${resp}=  Create Invoice   ${category_id}  ${DAY1}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid2}   ${resp.json()['uidList'][0]}  

        ${resp}=  Get Invoice By Id  ${invoice_uid2}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${Total}  ${resp.json()['netTotal']}  

        ${note}=    FakerLibrary.word
        ${resp}=  Make Payment By Cash For Invoice   ${invoice_uid2}  ${payment_modes[0]}  ${Total}  ${note}  paymentOndate=${DAY1}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        #--------------3rd Appointment- Take appt for one service, Add sub service in that appt's invoice ------------------

        ${slot}=  Get Random Slot  ${sch_id}  ${DAY1}  ${s_id2}

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        ${quantity}=   Random Int  min=1  max=10
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
        ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}
        ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
        # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
        ${invoiceId}=  FakerLibrary.iana_id

        ${resp}=  Create Invoice   ${category_id}  ${DAY1}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid3}   ${resp.json()['uidList'][0]}  

        ${resp}=  Get Invoice By Id  ${invoice_uid3}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Set Test Variable  ${Total}  ${resp.json()['netTotal']}
        
        
        #--------------4th Appointment- Take appt for one service, Add sub service in that appt's invoice and also assign that sub service to a user ------------------

        ${slot}=  Get Random Slot  ${sch_id}  ${DAY1}  ${s_id2}

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        ${quantity}=   Random Int  min=1  max=10
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${user_id}=  Evaluate  random.choice($user_list)  random
        ${assigneeUsers}=  Create List  ${user_id}
        ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
        ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}   assigneeUsers=${assigneeUsers}
        ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
        # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
        ${invoiceId}=  FakerLibrary.iana_id

        ${resp}=  Create Invoice   ${category_id}  ${DAY1}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid4}   ${resp.json()['uidList'][0]}  

        ${resp}=  Get Invoice By Id  ${invoice_uid4}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        #-------------------------5th Appointment-Take an appt then apply service level discount-------------------------------

        ${slot}=  Get Random Slot  ${sch_id}  ${DAY1}  ${s_id2}

        ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
        ${apptfor}=   Create List  ${apptfor1}

        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${wapptid1}  ${apptid[0]}

        ${resp}=  Get Appointment By Id   ${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${providerConsumerIdList}=  Create List  ${cid${i}}
        ${quantity}=   Random Int  min=1  max=10
        ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
        ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
        ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
        ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
        ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}
        ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
        # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
        ${invoiceId}=  FakerLibrary.iana_id

        ${resp}=  Create Invoice   ${category_id}  ${DAY1}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable   ${invoice_uid5}   ${resp.json()['uidList'][0]}  

        ${privateNote}=     FakerLibrary.word
        ${displayNote}=   FakerLibrary.word
        # ${discountValue1}=     Random Int   min=50   max=100
        # ${discountValue1}=  Convert To Number  ${discountValue1}  1

        ${resp}=  Apply Service Level Discount   ${invoice_uid5}   ${discountId}  ${discountprice}  ${privateNote}  ${displayNote}  ${s_id2}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Invoice By Id  ${invoice_uid5}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        #-------------------------6th Appointment-Take appointments for past dates- Nested FOR LOOP -------------------------------
        FOR  ${j}  IN RANGE   ${max_days}

            ${DAY2}=  db.subtract_timezone_date  ${tz}   ${j+1}

            ${slot}=  Get Random Slot  ${sch_id}  ${DAY2}  ${s_id2}

            ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
            ${apptfor}=   Create List  ${apptfor1}

            ${cnote}=   FakerLibrary.word
            ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY2}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
            Set Test Variable  ${wapptid1}  ${apptid[0]}

            ${resp}=  Get Appointment By Id   ${wapptid1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

            ${providerConsumerIdList}=  Create List  ${cid${i}}
            ${quantity}=   Random Int  min=1  max=10
            ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
            ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
            ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
            IF    ${j} % 3 == 0
                ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
                ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
            ELSE IF    ${j} % 4 == 0
                ${user_id}=  Evaluate  random.choice($user_list)  random
                ${assigneeUsers}=  Create List  ${user_id}
                ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
                ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}  assigneeUsers=${assigneeUsers}
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
            ELSE
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}
            END
            # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
            ${invoiceId}=  FakerLibrary.iana_id
            
            ${resp}=  Create Invoice   ${category_id}  ${DAY2}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable   ${invoice_uid6}   ${resp.json()['uidList'][0]}  

            ${random_days}=   Evaluate  random.sample(range(int(${max_days})), int(${max_days}/2))  random
            IF  ${j} in @{random_days}
                ${privateNote}=     FakerLibrary.word
                ${displayNote}=   FakerLibrary.word
                ${resp}=  Apply Service Level Discount   ${invoice_uid6}   ${discountId}  ${discountprice}  ${privateNote}  ${displayNote}  ${s_id2}
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200
            END

            ${resp}=  Get Invoice By Id  ${invoice_uid6}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END

    #-------------------------7th Appointment-Take appointments for future- Nested FOR LOOP -------------------------------
        FOR  ${j}  IN RANGE   ${max_days}

            ${DAY2}=  db.add_timezone_date  ${tz}   ${j+1}

            ${slot}=  Get Random Slot  ${sch_id}  ${DAY2}  ${s_id2}

            ${apptfor1}=  Create Dictionary  id=${cid${i}}   apptTime=${slot}
            ${apptfor}=   Create List  ${apptfor1}

            ${cnote}=   FakerLibrary.word
            ${resp}=  Take Appointment For Consumer  ${cid${i}}  ${s_id2}  ${sch_id}  ${DAY2}  ${cnote}  ${apptfor}  location=${{str('${lid}')}} 
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
            Set Test Variable  ${wapptid1}  ${apptid[0]}

            ${resp}=  Get Appointment By Id   ${wapptid1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

            ${providerConsumerIdList}=  Create List  ${cid${i}}
            ${quantity}=   Random Int  min=1  max=10
            ${servicecharge}=   Pyfloat  right_digits=1  min_value=100  max_value=250
            ${serviceList1}=  Create Dictionary  serviceId=${s_id1}   quantity=${quantity} 
            ${serviceList2}=  Create Dictionary  serviceId=${s_id2}   quantity=${quantity}    price=${servicecharge}
            IF    ${j} % 3 == 0
                ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
                ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
            ELSE IF    ${j} % 4 == 0
                ${user_id}=  Evaluate  random.choice($user_list)  random
                ${assigneeUsers}=  Create List  ${user_id}
                ${subservicecharge}=   Pyfloat  right_digits=1  min_value=50  max_value=100
                ${serviceList3}=  Create Dictionary  serviceId=${s_id3}   quantity=${quantity}    price=${subservicecharge}  assigneeUsers=${assigneeUsers}
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}  ${serviceList3}
            ELSE
                ${serviceList}=    Create List    ${serviceList1}   ${serviceList2}
            END
            # ${invoiceDate}=   db.get_date_by_timezone  ${tz}
            ${invoiceId}=  FakerLibrary.iana_id
            
            ${resp}=  Create Invoice   ${category_id}  ${DAY2}  ${invoiceId}  ${providerConsumerIdList}   ${lid}   serviceList=${serviceList}   ynwUuid=${wapptid1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable   ${invoice_uid7}   ${resp.json()['uidList'][0]}  

            ${random_days}=   Evaluate  random.sample(range(int(${max_days})), int(${max_days}/2))  random
            IF  ${j} in @{random_days}
                ${privateNote}=     FakerLibrary.word
                ${displayNote}=   FakerLibrary.word
                ${resp}=  Apply Service Level Discount   ${invoice_uid7}   ${discountId}  ${discountprice}  ${privateNote}  ${displayNote}  ${s_id2}
                Log  ${resp.content}
                Should Be Equal As Strings  ${resp.status_code}  200
            END

            ${resp}=  Get Invoice By Id  ${invoice_uid7}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
        END


    END



    