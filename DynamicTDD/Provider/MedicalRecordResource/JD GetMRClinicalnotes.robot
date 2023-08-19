*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        MR
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py

*** Variables ***
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${self}                   0

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

${order}    0
${fileSize}  0.00458


*** Test Cases ***

JD-TC-GetMRClinicalnotes-1
    [Documentation]   Get MR Clinicalnotes for a waitlist(Walk-in).
    
    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+7850037
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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}

    ${pid}=  get_acc_id  ${PUSERNAME_C}
    Set Suite Variable  ${pid}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_C}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_C}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
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
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable     ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00    
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid1}  ${bookingType[0]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mr_id1}   ${resp.json()}

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
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}
   

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

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

    ${attachment}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment}
    Set Suite Variable  ${attachment}

    ${attachment1}=    Create Dictionary   action=${LoanAction[0]}  owner=${pid}  fileName=${pdffile}  fileSize=${fileSize}  caption=${caption}  fileType=${fileType}  order=${order}
    Log  ${attachment1}
    Set Suite Variable  ${attachment1}

    ${resp}=  Create MR clinical notes by mr id   ${mr_id1}   ${type}  ${clinicalNote}    ${attachment1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}

JD-TC-GetMRClinicalnotes-2
 
    [Documentation]   Get MR Clinicalnotes with consultation mode EMAIL for waitlist.

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+7850046
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
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}

    ${pid0}=  get_acc_id  ${PUSERNAME_D}
    Set Suite Variable  ${pid0}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_D}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_D}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=   Get Location ById  ${loc_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time1}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${strt_time1}
    ${end_time}=    add_timezone_time  ${tz}  3  00    
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
    ${resp}=  Add To Waitlist Consumers  ${pid0}  ${que_id2}  ${CUR_DAY}  ${ser_id2}  ${cnote}  ${bool[0]}  ${self}  
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

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid2}  ${bookingType[0]}  ${consultationMode[0]}  ${CUR_DAY}  ${status[0]} 
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
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}
   

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id2}   ${type}  ${clinicalNote}    ${attachment1}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
JD-TC-GetMRClinicalnotes-3

    [Documentation]   Get MR Clinicalnotes for a waitlist(online-in).

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200        

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
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

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR  ${wid}  ${bookingType[0]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME5}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
JD-TC-GetMRClinicalnotes-4
    [Documentation]   Get MR Clinicalnotes for family member's waitlist(online check-in).

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
    Set Test Variable  ${cid}  ${resp.json()[1]['id']}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Test Variable  ${fcid}  ${resp.json()[0]['id']}


    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${complaints3}=     FakerLibrary.word
    Set Suite Variable   ${complaints3}
    ${symptoms3}=      FakerLibrary.sentence
    Set Suite Variable   ${symptoms3}
    ${allergies3}=     FakerLibrary.sentence
    Set Suite Variable   ${allergies3}
    ${vacc_history3}=  FakerLibrary.sentence
    Set Suite Variable   ${vacc_history3}
    ${observations3}=  FakerLibrary.sentence
    Set Suite Variable   ${observations3}
    ${diagnosis3}=     FakerLibrary.sentence
    Set Suite Variable   ${diagnosis3}
    ${misc_notes3}=    FakerLibrary.sentence
    Set Suite Variable   ${misc_notes3}
    ${med_name}=      FakerLibrary.name
    ${frequency}=     FakerLibrary.word
    ${duration}=      FakerLibrary.sentence
    ${instrn}=        FakerLibrary.sentence
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${DAY}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${fcid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${firstname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}        ${lastname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}


    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   

JD-TC-GetMRClinicalnotes-5
    [Documentation]   Get MR Clinicalnotes of customer by using  family member's waitlisted Clinicalnotes(online check-in).

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}


    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self}  
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
    Set Test Variable  ${cid}  ${resp.json()[1]['id']}

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${DAY}  ${status[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}              ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}       ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}         ${CUSERNAME9}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}          ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                                ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                         ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                    ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                       ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                  ${C_date} ${strt_time}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}                 ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                       ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                         ${id}


    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
JD-TC-GetMRClinicalnotes-6
    [Documentation]   Get MR Clinicalnotes for appointment(walkin).

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
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
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

    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
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

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${DAY1}  ${status[0]}   
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
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   

JD-TC-GetMRClinicalnotes-7
    [Documentation]   Get MR Clinicalnotes for appointment(online)

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
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${num_slots}=  Get Length  ${slots}
    ${j}=  Random Int  max=${num_slots-1}
    Set Suite Variable   ${slot1}   ${slots[${j}]}

    ${converted_slot2}=  convert_slot_12hr_first  ${slot1}

    ${apptfor1}=  Create Dictionary  id=${self}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${cid}=  get_id  ${CUSERNAME7}   
    Set Suite Variable   ${cid}
    ${cnote}=   FakerLibrary.name
    ${resp}=   Take Appointment For Provider   ${pid}  ${ser_id1}  ${sch_id}  ${DAY1}  ${cnote}   ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

    ${resp}=   Get consumer Appointment By Id   ${pid}  ${apptid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['uid']}                                           ${apptid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                                ${cid}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['firstName']}          ${fname}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['lastName']}           ${lname}
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


    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${DAY1}  ${status[0]}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME7}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${converted_slot2}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
JD-TC-GetMRClinicalnotes-8
    [Documentation]  User Get MR Clinicalnotes (waitlist for current day)

    ${iscorp_subdomains}=  get_iscorp_subdomains   1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+8840233
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id3}  ${decrypted_data['id']}
    Set Suite Variable  ${userName3}  ${decrypted_data['userName']}
    # Set Test Variable    ${id3}    ${resp.json()['id']} 
    # Set Test Variable    ${userName3}    ${resp.json()['userName']} 
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
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

    ${id}=  get_id  ${MUSERNAME_E}
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
    Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+886141
    clear_users  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${user_dis_name}=  FakerLibrary.last_name
    Set Suite Variable  ${user_dis_name}
    ${employee_id}=  FakerLibrary.last_name
    Set Suite Variable  ${employee_id}
  
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id}  ${resp.json()}

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
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  2  30  

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=05  max=10   
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id}  ${resp.json()}
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.bs
    Set Test Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

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

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${wid}  ${bookingType[0]}  ${consultationMode[3]}  ${CUR_DAY}  ${status[0]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME1}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${wid}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[0]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${s_id}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime1}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id3}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
JD-TC-GetMRClinicalnotes-9
    [Documentation]  Provider takes appointment for a consumer and create Mr Clinicalnotes and reschedules it to a later time in the same day and then get Clinicalnotes
    
    ${resp}=  Consumer Login  ${CUSERNAME33}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

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
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime4}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime4}
    ${delta}=  FakerLibrary.Random Int  min=20  max=60
    ${eTime1}=  add_two   ${sTime4}  ${delta}
    ${schedule_name1}=  FakerLibrary.bs
    Set Suite Variable   ${schedule_name1}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=1
    Set Suite Variable   ${parallel} 
    ${maxval}=  Convert To Integer   ${delta/4}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime4}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id2}  ${duration}  ${bool1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sch_id1}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][3]['time']}

    ${statusUpdatedTime0}=  convert_slot_12hr_first  ${slot2}

    ${resp}=  AddCustomer  ${CUSERNAME33}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${apptTime}=  db.get_tz_time_secs  ${tz} 
    ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
    ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id2}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id2}
    Set Test Variable  ${appttime1}   ${resp.json()['apptTakenTime']}
    ${apptTakenTime1}=  db.remove_secs   ${appttime1}
    Should Be Equal As Strings    ${apptTakenTime1}    ${apptTakenTime}
    Set Test Variable  ${updatedtime1}   ${resp.json()['statusUpdatedTime']}
    ${statusUpdatedTime1}=  db.remove_date_time_secs   ${updatedtime1}
    Should Be Equal As Strings    ${statusUpdatedTime1}    ${statusUpdatedTime}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   0
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['time']}   ${slot2}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['noOfAvailbleSlots']}   ${parallel}


    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME33}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime4}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   

    ${resp}=  Reschedule Consumer Appointment   ${apptid1}  ${slot2}  ${DAY1}  ${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id2}
    Set Test Variable  ${appttime1}   ${resp.json()['apptTakenTime']}
    ${apptTakenTime1}=  db.remove_secs   ${appttime1}
    Should Be Equal As Strings    ${apptTakenTime1}    ${apptTakenTime}
    Set Test Variable  ${updatedtime1}   ${resp.json()['statusUpdatedTime']}
    ${statusUpdatedTime1}=  db.remove_date_time_secs   ${updatedtime1}
    Should Be Equal As Strings    ${statusUpdatedTime1}    ${statusUpdatedTime}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['time']}   ${slot2}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['noOfAvailbleSlots']}   0

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   

JD-TC-GetMRClinicalnotes-10
    [Documentation]  Provider takes appointment for a consumer and create Mr Clinicalnotes and reschedules it to a next day and then get Clinicalnotes
    
    ${resp}=  Consumer Login  ${CUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}   name=${schedule_name1}  apptState=${Qstate[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][3]['time']}

    ${statusUpdatedTime0}=  convert_slot_12hr_first  ${slot2}

    ${resp}=  AddCustomer  ${CUSERNAME34}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${apptTime}=  db.get_tz_time_secs  ${tz} 
    ${apptTakenTime}=  db.remove_secs   ${apptTime}
    ${UpdatedTime}=  db.get_date_time_by_timezone  ${tz}
    ${statusUpdatedTime}=   db.remove_date_time_secs   ${UpdatedTime}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${ser_id2}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
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
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY1}   appmtTime=${slot1}  
    ...   appointmentEncId=${encId}  apptStatus=${apptStatus[1]}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot1}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id2}
    Set Test Variable  ${appttime1}   ${resp.json()['apptTakenTime']}
    ${apptTakenTime1}=  db.remove_secs   ${appttime1}
    Should Be Equal As Strings    ${apptTakenTime1}    ${apptTakenTime}
    Set Test Variable  ${updatedtime1}   ${resp.json()['statusUpdatedTime']}
    ${statusUpdatedTime1}=  db.remove_date_time_secs   ${updatedtime1}
    Should Be Equal As Strings    ${statusUpdatedTime1}    ${statusUpdatedTime}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   0
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['time']}   ${slot2}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['noOfAvailbleSlots']}   0
    # Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['noOfAvailbleSlots']}   ${parallel}


    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
    ${CUR_DAY}=       db.get_date_by_timezone  ${tz}
    ${resp}=  Create MR   ${apptid1}  ${bookingType[1]}  ${consultationMode[3]}   ${CUR_DAY}  ${status[0]}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mr_id}   ${resp.json()}

    ${resp}=  Get MR By Id  ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}            ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['phoneNo']}       ${CUSERNAME34}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['status']}        ${status[0]}
    Should Be Equal As Strings  ${resp.json()['uuid']}                              ${apptid1}
    Should Be Equal As Strings  ${resp.json()['bookingType']}                       ${bookingType[1]}
    Should Be Equal As Strings  ${resp.json()['consultationMode']}                  ${consultationMode_verify[3]}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['mrConsultationDate']}                ${C_date} ${sTime4}
    Should Be Equal As Strings  ${resp.json()['prescriptionCreated']}               ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['mrCreatedDate']}                     ${C_date} ${ctime}
    Should Be Equal As Strings  ${resp.json()['mrCreatedBy']}                       ${id1}

    ${symptoms1}=      FakerLibrary.name
    ${allergies1}=     FakerLibrary.word
    ${diagnosis1}=     FakerLibrary.sentence
    ${complaints1}=    FakerLibrary.sentence
    ${misc_notes1}=    FakerLibrary.word
    ${observations1}=  FakerLibrary.sentence
    ${vaccinationHistory1}=  FakerLibrary.sentence

    ${resp}=  Create MR clinical notes by mr id   ${mr_id}   ${type}  ${clinicalNote}    ${attachment1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
    ${DAY3}=  db.add_timezone_date  ${tz}  4  

    ${resp}=  Reschedule Consumer Appointment   ${apptid1}  ${slot2}  ${DAY3}  ${sch_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}  uid=${apptid1}  appmtDate=${DAY3}   appmtTime=${slot2}  
    ...   appointmentEncId=${encId}  apptStatus=${apptStatus[1]}  
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['id']}   ${cid}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['providerConsumer']['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['service']['id']}   ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['schedule']['id']}   ${sch_id1}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['firstName']}   ${fname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['lastName']}   ${lname}
    Should Be Equal As Strings  ${resp.json()['appmtFor'][0]['apptTime']}   ${slot2}
    Should Be Equal As Strings  ${resp.json()['location']['id']}   ${loc_id2}
    Set Test Variable  ${appttime1}   ${resp.json()['apptTakenTime']}
    ${apptTakenTime1}=  db.remove_secs   ${appttime1}
    Should Be Equal As Strings    ${apptTakenTime1}    ${apptTakenTime}
    Set Test Variable  ${updatedtime1}   ${resp.json()['statusUpdatedTime']}
    ${statusUpdatedTime1}=  db.remove_date_time_secs   ${updatedtime1}
    Should Be Equal As Strings    ${statusUpdatedTime1}    ${statusUpdatedTime}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${ser_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleName=${schedule_name1}  scheduleId=${sch_id1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['time']}   ${slot1}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][0]['noOfAvailbleSlots']}   ${parallel}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['time']}   ${slot2}
    Should Be Equal As Strings   ${resp.json()['availableSlots'][3]['noOfAvailbleSlots']}   0

    ${resp}=  Get MR clinical notes   ${mr_id} 
    Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
   
 
JD-TC-GetMRClinicalnotes-UH1
    [Documentation]   Get MR Clinicalnotes for a canceled waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
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

    # ${ctime}=         db.get_time_by_timezone  ${tz}
    # ${ctime}=         db.get_time_by_timezone  ${tz}
    ${ctime}=         db.get_time_by_timezone  ${tz}_by_timezone  ${tz}
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

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${attachment}    ${attachment}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${attachment}    ${attachment1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}

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

    ${resp}=  Get MR clinical notes   ${mr_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   
    ${desc}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid3}  ${waitlist_cancl_reasn[4]}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Waitlist By Id  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Get MR clinical notes   ${mr_id3} 
    Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['type']}               ${type}
    Should Be Equal As Strings  ${resp.json()[0]['clinicalNotes']}              ${clinicalNote}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['owner']}              ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileName']}             ${pdffile}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['fileSize']}             ${fileSize}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['caption']}           ${caption}
    Should Be Equal As Strings  ${resp.json()[0]['attachments'][0]['action']}     ${LoanAction[0]}
   

JD-TC-GetMRClinicalnotes-UH2
    [Documentation]   Get MR Clinicalnotes for another provider's MR.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR clinical notes   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"

JD-TC-GetMRClinicalnotes-UH3
    [Documentation]   Get MR Clinicalnotes without login.
    ${resp}=  Get MR clinical notes   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-GetMRClinicalnotes-UH4
    [Documentation]   Get MR Clinicalnotes with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR clinical notes   ${mr_id1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetMRClinicalnotes-UH5
    [Documentation]   Get MR Clinicalnotes with invalid MR id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get MR clinical notes   000
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_NOT_FOUND}"

JD-TC-GetMRClinicalnotes-UH6
 
    [Documentation]    Get MR Clinicalnotes for a future waitlist(walk-in).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${desc}=   FakerLibrary.word
    ${FUT_DAY}=  db.add_timezone_date  ${tz}   3
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${que_id2}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid4} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${Notes}=    clinical Notes Attachments    ${type}  ${clinicalNote}    ${attachment}    ${attachment}

    ${Notes1}=    clinical Notes Attachments    ${type1}  ${clinicalNote1}    ${attachment}    ${attachment1}

    ${clinicalNotes}=  Create List   ${Notes}    ${Notes1}
   
    ${pre_list}=  Create Dictionary  medicine_name=${med_name}  frequency=${frequency}  duration=${duration}  instructions=${instrn}  dosage=${dosage}

    ${prescriptionsList}=  Create List   ${pre_list}

    ${prescriptions}=  Create Dictionary  prescriptionsList=${prescriptionsList}  notes=${Pres_notes}

    ${resp}=  Create MR With uuid  ${wid4}  ${bookingType[0]}  ${consultationMode[3]}      ${FUT_DAY}    ${status[0]}     prescriptions=${prescriptions}    clinicalNotes=${clinicalNotes}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${MEDICAL_RECORD_WL_FUTURE_DATE}"


   
   