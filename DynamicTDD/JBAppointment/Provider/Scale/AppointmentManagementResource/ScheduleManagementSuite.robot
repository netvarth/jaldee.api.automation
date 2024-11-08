*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

${self}     0
@{service_names}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists


*** Test Cases ***

JD-TC-Schedule-1

    [Documentation]  Schedule workflow for pre deployment.

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup   Domain=${domain}   SubDomain=${subdomain}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

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

    # ........ Location Creation .......

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # ........ Service Creations ............

    #  1. Create Service without Prepayment.

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id1}=  Create Sample Service  ${SERVICE1}   
    Set Test Variable  ${s_id1}

    #  2. Create Service without Prepayment and Max Bookings Allowed > 1

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${s_id2}=  Create Sample Service  ${SERVICE2}      maxBookingsAllowed=10
    Set Test Variable  ${s_id2}

    #  3. Create Service without Prepayment and Max Bookings Allowed > 1

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${s_id2}=  Create Sample Service  ${SERVICE2}      maxBookingsAllowed=10
    Set Test Variable  ${s_id2}






    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    
    
    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id} 
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_amount1}  ${resp.json()['totalAmount']} 

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j1}]}
    IF  ${resp.json()['availableSlots'][${j1}]['noOfAvailbleSlots']} == 0   
        Remove From List    ${slots}    ${slot1}
    END
    ${j1}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot2}   ${slots[${j1}]}

    ${NewCustomer}    Generate random string    10    123456789
    ${NewCustomer}    Convert To Integer  ${NewCustomer}
    Set Suite variable   ${NewCustomer}
    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=  AddCustomer  ${NewCustomer}   firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}   email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${cid}  ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}  location=${{str('${lid}')}}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #.....Apply Label ..............

    clear_Label  ${PUSERNAME_B}

    ${label_id}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name}  ${lbl_value}

    ${resp}=  Add Label for Multiple Appointment   ${label_dict}  ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${lbl_name}=${lbl_value}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['label']}  ${label}

    #..... Send Message .............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${apptid1}

    ${resp}=    Send Message With Appointment   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    #.... Send Attachment ............

    # ${resp}=  Send Attachment From Appointment   ${apptid1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Appointment     ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence
    ${type}=     FakerLibrary.word
    ${clinicalNote}=     FakerLibrary.word
    ${clinicalNote1}=        FakerLibrary.sentence
    ${type1}=        FakerLibrary.sentence
   
    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    ${caption}=  Fakerlibrary.Sentence
   
    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
   
    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${pid}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Test Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Test Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    ${note}=  FakerLibrary.Text  max_nb_chars=42 

    ${resp}=    Create Prescription    ${cid}    ${pid}      ${html}     ${mrPrescriptions}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Test Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Test Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']}

    ${resp1}=  Get Prescription By UID    ${prescription_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    #......... Share Prescription to patient...........

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To Patient   ${prescription_uid}    ${message}    ${bool[1]}      
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    #......... Share Prescription to thirdparty...........

    ${fname}=  generate_firstname
    Set Test Variable  ${emailid1}  ${fname}${C_Email}.${test_mail}
    ${resp}=    Share Prescription To ThirdParty   ${prescription_uid}    ${message}     ${emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}     ${bool[1]}

    #.......... Case Creation and share case............

    ${doctor}=  Create Dictionary  id=${provider_id} 
    ${consumer}=  Create Dictionary  id=${cid} 
    ${title}=  FakerLibrary.name

    ${resp}=  Create Case   ${title}  ${doctor}  ${consumer}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${case_id}   ${resp.json()['uid']}

    ${message}=  FakerLibrary.sentence
    ${medium}=  Create Dictionary  email=${bool[1]} 
    
    ${resp}=  Share Case Pdf  ${case_id}  ${bool[1]}  ${bool[0]}  ${consumer}  ${doctor}  ${message}  ${medium}  html=${html}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #....... Treatment plan ...........

    ${treatment}=  FakerLibrary.name
    ${work}=  FakerLibrary.name
    ${one}=  Create Dictionary  work=${work}   status=${PRStatus[0]}
    ${works}=  Create List  ${one}

    ${resp}=    Create Treatment Plan    ${case_id}    ${treatment}  ${works}  
    Log   ${resp.json()}
    Should Be Equal As Strings              ${resp.status_code}   200
    Set Test Variable    ${treatmentId}        ${resp.json()}

    #........ Auto Invoice Generation off and Create Invoice for booking ...........

    ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${apptid1}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_INVOICE_GENERATED}

    ${resp}=  Create Invoice for Booking  ${invoicebooking[0]}   ${apptid1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid}    ${resp.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${ser_amount1}
    Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    
    ##....subservice creation..........

    ${subser_name}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${subser_name}
    ${subser_id1}=  Create Sample Service    ${subser_name}    serviceCategory=${serviceCategory[0]}
   
    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.content}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_price}  ${resp.json()['totalAmount']} 
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${subser_qnty}=   Random Int   min=1   max=5
    ${ser_list}=  Create Dictionary  serviceId=${subser_id1}    price=${subser_price}  quantity=${subser_qnty}
   
    # ........ Add SubService To Invoice ...........

    ${resp}=  AddServiceToInvoice   ${invoice_uid}   ${ser_list}    
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${total}=    Evaluate    ${subser_qnty}*${subser_price} + ${ser_amount1}

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Numbers   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Numbers   ${resp.json()[0]['amountDue']}                                       ${total}
    Should Be Equal As Numbers   ${resp.json()[0]['amountTotal']}                                     ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}
    
    # ........ Add Item To Invoice ...........

    ${name1}=     FakerLibrary.word
    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    ${resp}=  Create Sample Item   ${name1}   ${item1}  ${itemCode1}  ${price}  ${bool[0]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${item_id1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${promotionalPrice1}   ${resp.json()['promotionalPrice']}
    
    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList1}=  Create Dictionary  itemId=${item_id1}   quantity=${quantity}  price=${promotionalPrice1}
    ${netTotal1}=  Evaluate  ${quantity} * ${promotionalPrice1}
    Set Test Variable   ${netTotal1}

    ${total_amount}=  Evaluate  ${netTotal1} + ${total}

    ${resp}=  AddItemToInvoice   ${invoice_uid}   ${itemList1}    
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Bookings Invoices  ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${apptid1}
    Should Be Equal As Numbers   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Numbers   ${resp.json()[0]['amountDue']}                                       ${total_amount}
    Should Be Equal As Numbers   ${resp.json()[0]['amountTotal']}                                     ${total_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}                            ${item_id1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemName']}                          ${item1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}                          ${quantity}
    
    # ...... Reschedule Appointment .............

    ${resp}=  Reschedule Consumer Appointment   ${apptid1}  ${slot2}  ${DAY1}  ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}

    # ....... cancel the Appointment ..........
    
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=  Appointment Action   ${apptStatus[4]}   ${apptid1}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[4]}

