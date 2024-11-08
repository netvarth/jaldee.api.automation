*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
# Variables         /ebs/TDD/varfiles/providers.py
# Variables         /ebs/TDD/varfiles/consumerlist.py 
# Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables          ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

*** Variables ***
@{Views}  self  all  customersOnly
${count}  ${50}
${zero}        0
@{emptylist}

${self}         0
@{service_names}
&{Emptydict}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists

${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt

*** Test Cases ***
JD-TC-PreDeploymentWaitlist-1
    [Documentation]   Waitlist workflow for pre-deployment.

    # ${firstname}  ${lastname}  ${PUSERNAME_A}  ${LoginId}=  Provider Signup     Domain=${domain}   SubDomain=${subdomain}
    # Set Suite Variable  ${PUSERNAME_A}
    # ${num}=  find_last  ${var_file}
    # ${num}=  Evaluate   ${num}+1
    # Append To File  ${data_file}  ${LoginId} - ${PASSWORD}${\n}
    # Append To File  ${var_file}  PUSERNAME${num}=${LoginId}${\n}

    ${PUSERNAME_A}=  Set Variable  ${PUSERNAME3}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id}  ${decrypted_data['id']}
    Set Suite Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=  Get Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}   
        ${resp}=   Enable Waitlist
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['onlinePayment']}==${bool[0]}   
        ${resp}=   Enable Disable Online Payment   ${toggle[0]}
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

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    IF  ${resp.json()['onlinePresence']}==${bool[0]}
        ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${EMPTY}  ${EMPTY}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${loc_id1}=  Create Sample Location
        ${resp}=   Get Location ById  ${loc_id1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${fname}=  generate_firstname
        ${lname}=  FakerLibrary.last_name
        # ${NewCustomer}    Generate random string    10    123456789
        # ${NewCustomer}    Convert To Integer  ${NewCustomer}
        ${NewCustomer}=    Generate Random 555 Number
        Set Suite variable   ${NewCustomer}
        Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}
        ${resp}=  AddCustomer  ${NewCustomer}  firstName=${fname}   lastName=${lname}   email=${pc_emailid1}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid}  ${resp.json()}
    ELSE
        Set Test Variable  ${cid}  ${resp.json()[0]['id']}
        Set Test Variable  ${fname}  ${resp.json()[0]['firstName']}
    END

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}

    ${s_id}=  Set Variable  ${NONE}
    ${resp}=   Get Service  serviceType-neq=donationService
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    # IF   '${resp.content}' != '${emptylist}'
    IF   "$resp.content" != "${emptylist}"
        
        ${service_len}=  Get Length   ${resp.json()}
        FOR   ${i}  IN RANGE   ${service_len}
            IF  '${resp.json()[${i}]['status']}' == '${status[0]}'
                Set Test Variable   ${s_id}   ${resp.json()[${i}]['id']}

                IF  '${resp.json()[${i}]['isPrePayment']}' == '${bool[1]}'
                    ${maxbookings}=   Random Int   min=5   max=10
                    ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${resp.json()[${i}]['minPrePaymentAmount']}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                    Log  ${resp.content}
                    Should Be Equal As Strings  ${resp.status_code}  200
                ELSE

                    ${maxbookings}=   Random Int   min=5   max=10
                    ${resp}=  Update Service  ${s_id}  ${resp.json()[${i}]['name']}  ${EMPTY}  ${resp.json()[${i}]['serviceDuration']}  ${resp.json()[${i}]['status']}  ${btype}  ${resp.json()[${i}]['notification']}  ${resp.json()[${i}]['notificationType']}  ${EMPTY}  ${resp.json()[${i}]['totalAmount']}  ${resp.json()[${i}]['isPrePayment']}  ${resp.json()[${i}]['taxable']}  maxBookingsAllowed=${count}
                    Log  ${resp.content}
                    Should Be Equal As Strings  ${resp.status_code}  200

                END
                BREAK

            END
        END

        ${srv_val}=    Get Variable Value    ${s_id}
        IF  '${srv_val}'=='${None}'
            ${SERVICE1}=    FakerLibrary.job
            ${maxbookings}=   Random Int   min=5   max=10
            ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}
        END
    ELSE

        ${SERVICE1}=    FakerLibrary.job
        ${maxbookings}=   Random Int   min=5   max=10
        ${s_id}=  Create Sample Service  ${SERVICE1}  maxBookingsAllowed=${count}

    END

    ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_wl_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${prepay_wl_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        

    END

    ${resp}=  Get Waitlist Today  waitlistStatus-eq=${wl_status[0]}  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${prepay_wl_len}=  Get Length   ${resp.json()}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${prepay_wl_len}  ${zero}
    
    # ${resp}=  Get Waitlist Today   waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${today_wl_len}=  Get Length   ${resp.json()}
    # FOR   ${i}  IN RANGE   ${today_wl_len}

    #     ${resp1}=  Waitlist Action  ${waitlist_actions[4]}   ${resp.json()[${i}]['ynwUuid']}
    #     Log  ${resp1.content}
    #     Should Be Equal As Strings  ${resp1.status_code}  200      

    # END

    ${resp}=  Get Waitlist Today   waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_wl_len}=  Get Length   ${resp.json()}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${today_wl_len}  ${zero}

    ${resp}=  Get Waitlist Today
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${today_wl_len}=  Get Length   ${resp.json()}

    ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_wl_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${future_wl_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[2]}   ${resp.json()[${i}]['ynwUuid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Waitlist Future  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_wl_len}=  Get Length   ${resp.json()}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${future_wl_len}  ${zero}

    ${resp}=  Get Waitlist Future
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${future_wl_len}=  Get Length   ${resp.json()}

    ${resp}=  Get Provider Waitlist History  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${past_wl_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${past_wl_len}

        ${resp1}=  Waitlist Action  ${waitlist_actions[2]}   ${resp.json()[${i}]['ynwUuid']}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        
    END

    ${resp}=  Get Provider Waitlist History  waitlistStatus-neq=${wl_status[5]},${wl_status[4]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${past_wl_len}=  Get Length   ${resp.json()}
    # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${past_wl_len}  ${zero}

    ${resp}=  Get Provider Waitlist History  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${past_wl_len}=  Get Length   ${resp.json()}

    ${resp}=  Get Queues
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${queues_count}=  Get Length  ${resp.json()}

    ${resp}=  Get Queues  state-eq=${Qstate[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${queues_count}=  Get Length  ${resp.json()}
    FOR   ${i}  IN RANGE   ${queues_count}

        ${resp1}=  Enable Disable Queue  ${resp.json()[${i}]['id']}     ${Qstate[1]}
        Log  ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END


    ${DAY}=  get_date_by_timezone  ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz} 
    ${eTime1}=  add_timezone_time  ${tz}  0  45  
    ${p1queue1}=    FakerLibrary.job
    ${capacity}=  IF    ${count} > 50    Convert To Integer   ${count}    ELSE    FakerLibrary.Random Int  min=${count}  max=${count+20}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}



    ${desc}=  FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${wid}  ${resp.json()['parent_uuid']}


    #.....Apply Label ..............
    ${label_id}=   Create Sample Label

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary    ${lbl_name}    ${lbl_value}
    ${resp}=  Add Label for Multiple Waitlist   ${label_dict}    ${wid}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #..... Send Message .............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}
    Set Suite Variable    ${S3_url}    ${resp.json()[0]['url']}

    ${resp}=    Upload File To S3    ${S3_url}      ${jpgfile}

    ${resp}=    Update Status File Share    ${QnrStatus[1]}     ${driveId}

    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId}  action=${file_action[0]}  ownerName=${pdrname}
    ${attachment}=   Create List  ${attachments}

    ${uuid}=    Create List  ${wid}

    ${resp}=    Send Message With Waitlist   ${caption1}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  attachments=${attachment}  uuid=${uuid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #.... Send Attachment ............

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption1}    ${fileType1}    ${EMPTY}    ${order}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId1}    ${resp.json()[0]['driveId']}
    Set Suite Variable    ${S3_url1}    ${resp.json()[0]['url']}

    ${resp}=    Upload File To S3    ${S3_url1}      ${jpgfile}

    ${resp}=    Update Status File Share    ${QnrStatus[1]}     ${driveId1}


    ${attachments}=  Create Dictionary  owner=${provider_id}  fileName=${fileName}  fileSize=${fileSize}  fileType=${fileType1}  order=${order}  driveId=${driveId1}  action=${file_action[0]}  ownerName=${pdrname}

    ${resp}=  Send Attachment From Waitlist    ${wid}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${boolean[1]}  ${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Attachments In Waitlist     ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    #..........Prescription creation ............

    ${med_name}=      FakerLibrary.name
    Set Suite Variable    ${med_name}
    ${frequency}=     FakerLibrary.word
    Set Suite Variable    ${frequency}
    ${duration}=      FakerLibrary.sentence
    Set Suite Variable    ${duration}
    ${instrn}=        FakerLibrary.sentence
    Set Suite Variable    ${instrn}
    ${dosage}=        FakerLibrary.sentence
    Set Suite Variable    ${dosage}
    ${type}=     FakerLibrary.word
    Set Suite Variable    ${type}
    ${clinicalNote}=     FakerLibrary.word
    Set Suite Variable    ${clinicalNote}
    ${clinicalNote1}=        FakerLibrary.sentence
    Set Suite Variable    ${clinicalNote1}
    ${type1}=        FakerLibrary.sentence
    Set Suite Variable    ${type1}


    ${resp}=  db.getType   ${pdffile} 
    Log  ${resp}
    ${fileType}=  Get From Dictionary       ${resp}    ${pdffile} 
    Set Suite Variable    ${fileType}
    ${caption}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption}

    ${resp}=  db.getType   ${jpgfile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${jpgfile}
    Set Suite Variable    ${fileType1}
    ${caption1}=  Fakerlibrary.Sentence
    Set Suite Variable    ${caption1}


    ${resp}    upload file to temporary location    ${LoanAction[0]}    ${provider_id}    ${ownerType[0]}    ${pdrname}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}  
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}    200 
    Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    ${prescriptionAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${provider_id}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}   driveId=${driveId}
    Log  ${prescriptionAttachments}
    ${prescriptionAttachments}=  Create List   ${prescriptionAttachments}
    Set Suite Variable    ${prescriptionAttachments}

    ${mrPrescriptions}=  Create Dictionary  medicineName=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    Set Suite Variable    ${mrPrescriptions}
    ${note}=  FakerLibrary.Text  max_nb_chars=42 

    ${resp}=    Create Prescription    ${cid}    ${provider_id}      ${html}     ${mrPrescriptions}    prescriptionNotes=${note}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${prescription_uid}   ${resp.json()}

    ${resp}=    Get Prescription By Provider consumer Id   ${cid}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${referenceId}   ${resp.json()[0]['referenceId']}   
    Set Suite Variable  ${uid}   ${resp.json()[0]['uid']}
    Set Suite Variable  ${prescriptionStatus}   ${resp.json()[0]['prescriptionStatus']}
    

    ${resp1}=  Get Prescription By UID    ${prescription_uid}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200


    #......... Share Prescription to patient...........

    ${message}=  Fakerlibrary.Sentence
    Set Test Variable    ${message}

    ${resp}=    Share Prescription To Patient   ${prescription_uid}    ${message}    ${bool[1]} 
    # ${bool[1]}       ${bool[1]}    ${bool[1]}    ${bool[1]}  
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
    
    ${resp}=  Share Case Pdf  ${case_id}  ${bool[1]}  ${bool[0]}  ${consumer}  ${doctor}  ${message}  ${medium}     html=${html}
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

    ${NO_INVOICE_GENERATED}=  format String   ${NO_INVOICE_GENERATED}   ${wid}

    ${resp}=  Get Bookings Invoices  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${NO_INVOICE_GENERATED}

    ${resp}=  Create Invoice for Booking  ${invoicebooking[0]}   ${wid}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get Bookings Invoices  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable    ${invoice_uid}    ${resp.json()[0]['invoiceUid']}
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    # Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${wid}
    # Should Be Equal As Strings   ${resp.json()[0]['amountPaid']}                                      0.0
    # Should Be Equal As Strings   ${resp.json()[0]['amountDue']}                                       ${ser_amount1}
    # Should Be Equal As Strings   ${resp.json()[0]['amountTotal']}                                     ${ser_amount1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}

    #....subservice creation..........

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

    # ${total}=    Evaluate    ${subser_qnty}*${subser_price} + ${ser_amount1}

    ${resp}=  Get Bookings Invoices  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    # Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${wid}
    Should Be Equal As Numbers   ${resp.json()[0]['amountPaid']}                                      0.0
    # Should Be Equal As Numbers   ${resp.json()[0]['amountDue']}                                       ${total}
    # Should Be Equal As Numbers   ${resp.json()[0]['amountTotal']}                                     ${total}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}.0
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}

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

    ${resp}=  Get Bookings Invoices  ${wid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}                                        ${account_id}
    Should Be Equal As Strings  ${resp.json()[0]['categoryName']}                                     ${CategoryName[0]}
    Should Be Equal As Strings  ${resp.json()[0]['invoiceDate']}                                      ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['providerConsumerId']}                               ${cid}
    # Should Be Equal As Strings  ${resp.json()[0]['providerConsumerData']['phoneNos'][0]['number']}    ${NewCustomer}
    Should Be Equal As Strings   ${resp.json()[0]['ynwUuid']}                                         ${wid}
    Should Be Equal As Numbers   ${resp.json()[0]['amountPaid']}                                      0.0
    Should Be Equal As Numbers   ${resp.json()[0]['amountDue']}                                       ${total_amount}
    Should Be Equal As Numbers   ${resp.json()[0]['amountTotal']}                                     ${total_amount}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceId']}                      ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceName']}                    ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['quantity']}                       1.0
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['taxable']}                        ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['totalPrice']}                     ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['netRate']}                        ${ser_amount1}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['serviceCategory']}                ${serviceCategory[1]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][0]['assigneeUsers']}                  ${empty_list}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceId']}                      ${subser_id1}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceName']}                    ${subser_name}
    Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['quantity']}                       ${subser_qnty}.0
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['taxable']}                        ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()[0]['serviceList'][1]['serviceCategory']}                ${serviceCategory[0]}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemId']}                            ${item_id1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['itemName']}                          ${item1}
    Should Be Equal As Strings  ${resp.json()[0]['itemList'][0]['quantity']}                          ${quantity}

    # ...... Reschedule Waitlist .............

    ${resp}=  Reschedule Consumer Checkin   ${wid}  ${slot2}  ${DAY1}  ${sch_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}

    # ....... cancel the Waitlist ..........
    
    ${reason}=  Random Element  ${cancelReason}
    ${resp}=   Waitlist Action   ${waitlist_actions[2]}   ${wid}    cancelReason=${reason}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${wid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${waitlist_actions[2]}
