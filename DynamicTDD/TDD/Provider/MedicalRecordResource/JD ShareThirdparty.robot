*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        MR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${self}                   0
@{provider_list}
${start}                  0

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458

*** Test Cases ***

JD-TC-ShareprescriptionThirdparty-1
    [Documentation]   Share prescription to thirdparty for a waitlist(Walk-in)
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7862131
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    Set Suite Variable  ${userName}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName}    ${resp.json()['userName']}         
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    # ${pid}=  get_acc_id  ${PUSERNAME_C}
    # Set Suite Variable  ${pid}

    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # ${ph3}=  Evaluate  ${PUSERNAME230}+72002
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${CUR_DAY}
    ${C_date}=  Convert Date  ${CUR_DAY}  result_format=%d-%m-%Y
    Set Suite Variable   ${C_date}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}  
    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']} 
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable   ${strt_time}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1}  location=${loc_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${Pres_notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

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

    ${aadhaarAttachments}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments}

    ${aadhaarAttachments1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${aadhaarAttachments1}

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${aadhaarAttachments}    ${aadhaarAttachments}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${aadhaarAttachments}    ${aadhaarAttachments1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
    Set Suite Variable  ${clinicalNotes}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}
    
    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}
    Set Suite Variable  ${prescriptions}

    ${resp}=  Create MR With uuid  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Get MR By Id  ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}


    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id1}   ${msg}  ${html}   ${CUSERNAME2}   ${EMPTY}  ${boolean[1]}  ${expireTimeInMinuts}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ShareprescriptionThirdparty-2
 
    [Documentation]   Share prescription to thirdparty with mr consultation mode EMAIL for waitlist.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+7850438
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_D}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id1}  ${decrypted_data['id']}
    Set Suite Variable  ${userName1}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id1}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName1}    ${resp.json()['userName']}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    # ${pid0}=  get_acc_id  ${PUSERNAME_D}
    # Set Suite Variable  ${pid0}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pid0}  ${resp.json()['id']}

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id2}    ${resp} 
    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}   
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time1}=   db.add_timezone_time  ${tz}  1  00
    Set Suite Variable   ${strt_time1}
    ${end_time}=    db.add_timezone_time  ${tz}  3  00  
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  location=${loc_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid2}   ${bookingType[0]}  ${consultationMode[0]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id2}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id2}   ${msg}  ${html}   ${CUSERNAME2}   ${EMPTY}  ${boolean[1]}  ${expireTimeInMinuts}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ShareprescriptionThirdparty-3
 
    [Documentation]   Share prescription to thirdparty with medium as phone (online checkin)

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  location=${loc_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid2}  ${bookingType[0]}  ${consultationMode[0]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${CUSERNAME3}   ${EMPTY}  ${boolean[1]}  ${expireTimeInMinuts}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s

    ${resp}=  Consumer Login  ${CUSERNAME3}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-4
    [Documentation]   Share prescription to thirdparty for family member's waitlist(online check-in).

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}
       
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${cidfor}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    # ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}
    ${ctime}=         db.get_time_by_timezone   ${tz}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${Phone}=  Evaluate  ${PUSERNAME}+7812331
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${Phone}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-ShareprescriptionThirdparty-5
    [Documentation]   Share prescription to thirdparty for appointment(walkin).

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
 
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${ser_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}

    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${lname}${CUSERNAME8}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME8}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id1}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME8}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phone}=  Evaluate  ${PUSERNAME}+7812331
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${Phone}   ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-ShareprescriptionThirdparty-6
    [Documentation]   Share prescription to thirdparty for appointment(online)

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Suite Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Suite Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME7}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phone}=  Evaluate  ${PUSERNAME}+7812331
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${Phone}   ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   

JD-TC-ShareprescriptionThirdparty-7
    [Documentation]  Share prescription to thirdparty for family member's appointment(online check-in).

    ${resp}=  Consumer Login  ${CUSERNAME7}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME7}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${family_fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${family_lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}          ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                         ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                   ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                      ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                 ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}                ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                      ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                        ${id}
    

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phone}=  Evaluate  ${PUSERNAME}+7812331
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${Phone}   ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-ShareprescriptionThirdparty-8
    [Documentation]  User Share prescription to thirdparty (waitlist for current day)

    ${iscorp_subdomains}=  get_iscorp_subdomains   1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+8840217
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id3}  ${decrypted_data['id']}
    Set Suite Variable  ${userName3}  ${decrypted_data['userName']}
    # Set Suite Variable    ${id3}    ${resp.json()['id']} 
    # Set Suite Variable    ${userName3}    ${resp.json()['userName']}  
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
    Set Suite Variable  ${PUSERNAME_E}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_E}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_E}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
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
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  db.add_timezone_time  ${tz}  0  15
    ${eTime}=  db.add_timezone_time  ${tz}   0  45
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[1]}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s
    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}

    ${id}=  get_id  ${PUSERNAME_E}
    ${bs}=  FakerLibrary.bs
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+881341
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+876342
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime4}=  db.add_timezone_time  ${tz}  0  15
    Set Suite Variable  ${sTime4}
    ${eTime1}=  db.add_timezone_time  ${tz}   2  30

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime4}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}
   
    ${resp}=  Get User Search Status  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME1}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${cons_id}=  get_id  ${CUSERNAME1} 
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${DAY1}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id0}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id0} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${s_id}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime4}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}


    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${u_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${u_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phone}=  Evaluate  ${PUSERNAME}+7812331
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME1}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id0}   ${msg}  ${html}   ${Phone}   ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-UH1
    [Documentation]   Share prescription to thirdparty without using any medium

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id}   ${msg}  ${html}   ${EMPTY}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${PHONE_EMAIL_REQUIRED}"

JD-TC-ShareprescriptionThirdparty-UH2
    [Documentation]   share prescription to third party for a canceled waitlist (After prescription creation provider cancel the waitlist and try to share mr prescreption)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME2}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}   
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3}   location=${loc_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${wid3}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id3}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid3}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id3}   ${msg}  ${html}   ${CUSERNAME5}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CAN_NOT_CRETAE_PRESC_WL}"


JD-TC-ShareprescriptionThirdparty-UH3
    [Documentation]   Share prescription to thirdparty without msg.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Share Prescription Thirdparty   ${mr_id1}   ${EMPTY}  ${html}   ${CUSERNAME5}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MESSAGE_REQUIRED}"



JD-TC-ShareprescriptionThirdparty-UH4
    [Documentation]   Share prescription to thirdparty without html.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id1}   ${msg}  ${EMPTY}   ${CUSERNAME5}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${HTML_IMAGE_REQUIRED}"


JD-TC-ShareprescriptionThirdparty-UH5
    [Documentation]   Share prescription to thirdparty with invalid mrid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   000   ${msg}  ${EMPTY}   ${CUSERNAME5}   ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-ShareprescriptionThirdparty-UH6
    [Documentation]   Share prescription to thirdparty with another mrid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty   ${mr_id2}   ${msg}  ${html}   ${CUSERNAME5}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-ShareprescriptionThirdparty-UH7
    [Documentation]   Share prescription with consumer login.


    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

    # ${resp}=  Get digital sign   ${id} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${msg}=   FakerLibrary.word
    # ${resp}=  Share Prescription   ${mr_id1}   ${msg}  ${html}   ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  401
    # Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-ShareprescriptionThirdparty-UH8
    [Documentation]  share prescription to thirdparty for a canceled family member's appointment (After MR prescription creation consumer cancel the appointment and try to share mr prescreption)

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${f_Name1}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name1}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no1}  ${resp.json()['primaryPhoneNumber']}
   
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME17}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME17}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaint}=     FakerLibrary.word
    ${symptoms}=      FakerLibrary.sentence
    ${allergies}=     FakerLibrary.sentence
    ${vacc_history}=  FakerLibrary.sentence
    ${observations}=  FakerLibrary.sentence
    ${diagnosis}=     FakerLibrary.sentence
    ${misc_notes}=    FakerLibrary.sentence
    ${notes}=         FakerLibrary.sentence
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${dosage}=        FakerLibrary.sentence

    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}
    
    ${resp}=  Create MR With uuid  ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${family_fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${family_lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}


    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}    ${cid}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${appt_status[4]}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${html}   ${CUSERNAME17}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CAN_NOT_CRETAE_PRESC_APPT}"

# share prescription image to third party
JD-TC-ShareprescriptionThirdparty-9
    [Documentation]  Share prescription image to thirdparty for a waitlist(Walk-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME11} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
     
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    # ${complaints}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${clinicalNotes}=  Create Dictionary  symptoms=${symptoms}  allergies=${allergies}  diagnosis=${diagnosis}  complaints=${complaints}   misc_notes=${misc_notes}  observations=${observations}  vaccinationHistory=${vacc_history}  
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}   clinicalNotes=${clinicalNotes}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id4}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME11}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadPrescriptionImage   ${mr_id4}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=30   max=40 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id4}   ${msg}  ${EMPTY}   ${CUSERNAME11}  ${EMPTY}  ${boolean[1]}  ${expireTimeInMinuts}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-10
    [Documentation]   Share prescription image to thirdparty for a waitlist(Walk-in) and share through email, do not expirable
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    # ${ph3}=  Evaluate  ${PUSERNAME230}+72002
    Set Test Variable  ${email}  ${firstname}${CUSERNAME23}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME23}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}


    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${ctime}=         db.get_time_by_timezone   ${tz}
    # ${complaints}=     FakerLibrary.word
    # ${symptoms}=      FakerLibrary.sentence
    # ${allergies}=     FakerLibrary.sentence
    # ${vacc_history}=  FakerLibrary.sentence
    # ${observations}=  FakerLibrary.sentence
    # ${diagnosis}=     FakerLibrary.sentence
    # ${misc_notes}=    FakerLibrary.sentence
    # ${clinicalNotes}=  Create Dictionary  symptoms=${symptoms}  allergies=${allergies}  diagnosis=${diagnosis}  complaints=${complaints}   misc_notes=${misc_notes}  observations=${observations}  vaccinationHistory=${vacc_history}  
    
    ${resp}=  Create MR With uuid  ${wid}  ${bookingType[0]}  ${consultationMode[3]}      ${CUR_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}   clinicalNotes=${clinicalNotes}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid4}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME23}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail}
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${EMPTY}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-ShareprescriptionThirdparty-11
    [Documentation]   Share prescription image to third party for a online waitlist and share through email
    
    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}   location=${loc_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}


    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid2}  ${bookingType[0]}  ${consultationMode[0]}  ${CUR_DAY}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id5}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME13}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id5}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id5} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=10   max=30
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail} 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id5}   ${msg}  ${EMPTY}   ${EMPTY}  ${email}  ${boolean[1]}  ${expireTimeInMinuts}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
JD-TC-ShareprescriptionThirdparty-12
    [Documentation]   Share prescription image to thirdparty for a waitlist(online) and share through email and phone
    
    ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}   location=${loc_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid2}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid2}  ${bookingType[0]}  ${consultationMode[0]}  ${CUR_DAY}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME14}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid2}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[0]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
    

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${CUSERNAME5}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-13
    [Documentation]   Share prescription to thirdparty  for family member's waitlist(online check-in)and share through phone

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}
       
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${cidfor}   location=${loc_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid}  ${pid0}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}
    
    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${CUSERNAME17}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-14
    [Documentation]   Share prescription image to thirdparty for appointment(walkin). 

    ${resp}=  Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
 
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    # Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10      
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime2}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime2}=  add_two   ${sTime2}  ${delta}
    # ${s_id}=  Create Sample Service  ${SERVICE1}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  ${parallel}    ${parallel}  ${loc_id2}  ${duration}  ${bool1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    # ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}   ${resp.json()}

    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${lname}${CUSERNAME16}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${fname}  ${lname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME8}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id2}  ${sch_id1}  ${CUR_DAY}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment EncodedID   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appointmentEncId']}   ${encId}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[2]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id2}


    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail} 
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${EMPTY}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-ShareprescriptionThirdparty-15
    [Documentation]   Share prescription image to thirdparty for appointment(online)

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${f_Name}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no}  ${resp.json()['primaryPhoneNumber']}

    ${resp}=  Get Appointment Schedules Consumer  ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME19}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid0}  ${ser_id2}  ${sch_id1}  ${CUR_DAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid0}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${f_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${l_Name}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME19}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${f_Name}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${l_Name}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME3}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${EMPTY}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ShareprescriptionThirdparty-16
    [Documentation]  Share prescription image to third party for family member's appointment(online check-in).

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
   
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedules Consumer  ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id1}   ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id1}   ${pid0}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${cid}=  get_id  ${CUSERNAME20}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid0}  ${ser_id2}  ${sch_id1}  ${CUR_DAY}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid0}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${CUSERNAME20}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${CUR_DAY}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id2}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${family_fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${family_lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${CUSERNAME21}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-ShareprescriptionThirdparty-17
    [Documentation]  User Share prescription image to third party(waitlist for current day) and share through phone and email

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME2}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()[0]['id']}

    ${cons_id}=  get_id  ${CUSERNAME2} 
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid3}  ${s_id}  ${q_id}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}   
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid3}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid3}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Create MR  ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${s_id}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime4}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id3}

    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${u_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${u_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int    min=20   max=30
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME21}${C_Email}.${test_mail} 
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${CUSERNAME6}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-ShareprescriptionThirdparty-UH9
    [Documentation]   Share prescription image to third party for a  customer with invalid email(Walk-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_customer   ${PUSERNAME_C}
     
    ${resp}=  AddCustomer  ${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME26}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME26}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}88${C_Email}.ynwtest.netvarth.com 
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${CUSERNAME21}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings   ${resp.json()}   ${INVALID_EMAIL}"
    Should Be Equal As Strings   ${resp.json()}   Invalid email format

JD-TC-ShareprescriptionThirdparty-UH10
    [Documentation]   Share prescription image to thirdparty for a customer with invalid phone number (Walk-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer   account-eq=${cid} 
    Should Be Equal As Strings  ${resp.status_code}  200  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Create MR  ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}


    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${Phn}=  Evaluate  ${PUSERNAME}+1
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   345@  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${INVALID_PHONE}"


JD-TC-ShareprescriptionThirdparty-UH11
    [Documentation]   Share prescription image to third party without using any medium(Walk-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname}${CUSERNAME3}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME24}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME24}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Create MR  ${wid}  ${bookingType[0]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME24}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings   "${resp.json()}"   "${PHONE_EMAIL_REQUIRED}"

    
JD-TC-ShareprescriptionThirdparty-UH12
    [Documentation]   share prescription image to third party for a canceled waitlist (After prescription image upload provider cancel the waitlist and try to share mr prescreption image)

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstname}${CUSERNAME25}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME25}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}   
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id2}  ${que_id2}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${resp}=  Create MR   ${wid3}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id6}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid3}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME25}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid3}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   uploadPrescriptionImage   ${mr_id6}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadDigitalSign   ${id1}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${expireTimeInMinuts}=  Random Int   min=1   max=3 
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME2}${C_Email}.${test_mail}
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id6}   ${msg}  ${EMPTY}   ${EMPTY}  ${email}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CAN_NOT_CRETAE_PRESC_WL}"

    
JD-TC-ShareprescriptionThirdparty-UH13
    [Documentation]   Share prescription image to third party without msg.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id4}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phn}=  Evaluate  ${PUSERNAME}+876340
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id4}   ${EMPTY}  ${EMPTY}   ${Phn}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MESSAGE_REQUIRED}"


JD-TC-ShareprescriptionThirdparty-UH14
    [Documentation]   Share prescription image  to third party with invalid mrid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id4}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=   FakerLibrary.word
    ${Phn}=  Evaluate  ${PUSERNAME}+876340
    ${resp}=  Share Prescription Thirdparty   000   ${msg}  ${EMPTY}   ${Phn}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-ShareprescriptionThirdparty-UH15
    [Documentation]   Share prescription to third party with another mrid.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id4}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phn}=  Evaluate  ${PUSERNAME}+876340
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id5}   ${msg}  ${EMPTY}   ${Phn}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"


JD-TC-ShareprescriptionThirdparty-UH16
    [Documentation]  share prescription image to third party for a canceled family member's appointment (After MR prescription image upload consumer cancel the appointment and try to share mr prescreption)

    clear_customer   ${PUSERNAME_C}
    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${f_Name1}  ${resp.json()['firstName']}
    Set Test Variable  ${l_Name1}  ${resp.json()['lastName']}
    Set Test Variable  ${ph_no1}  ${resp.json()['primaryPhoneNumber']}
   
    ${family_fname}=  FakerLibrary.first_name
    ${family_lname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${family_fname}  ${family_lname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${resp}=  Get Appointment Schedules Consumer  ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById Consumer  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Next Available Appointment Slots By ScheduleId  ${sch_id}   ${pid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        IF  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   
            Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
        END
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Test Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${cidfor}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME17}   
    Set Test Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${f_Name1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${l_Name1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['primaryMobileNo']}    ${ph_no1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                                 ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}                                ${sch_id}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}                                    ${appt_status[1]}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}                      ${family_fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}                       ${family_lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}                       ${slot1}
    Should Be Equal As Strings  ${resp.json()['appmtDate']}                                     ${DAY1}
    Should Be Equal As Strings  ${resp.json()['appmtTime']}                                     ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}                                ${loc_id1}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  AddCustomer  ${CUSERNAME17}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cons_id}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cons_id}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${ctime}=         db.get_time_by_timezone   ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${family_fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${family_lname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadPrescriptionImage   ${mr_id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR prescription   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Cancel Appointment By Consumer  ${apptid1}   ${pid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['id']}    ${cid}
    Should Be Equal As Strings  ${resp.json()['apptStatus']}        ${appt_status[4]}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}    ${sch_id}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadDigitalSign   ${id}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get digital sign   ${id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Phn}=  Evaluate  ${PUSERNAME}+876340
    ${msg}=   FakerLibrary.word
    ${resp}=  Share Prescription Thirdparty  ${mr_id}   ${msg}  ${EMPTY}   ${Phn}  ${EMPTY}  ${boolean[0]}  0
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CAN_NOT_CRETAE_PRESC_APPT}"

