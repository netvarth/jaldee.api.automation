*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Queue
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${SERVICE8}  Threading
${SERVICE9}  Threading12
@{appointment}            Enable  Disable
${start}    10
*** Test Cases ***

JD-TC-CreateQueue-1
    [Documentation]    Create a queue in a location of a valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME4}
    clear_location  ${PUSERNAME4}
    clear_queue  ${PUSERNAME4}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

JD-TC-CreateQueue-2
    [Documentation]    Create a queue with same details of another provider
    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${start}  ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    ${domain}=   Set Variable    ${decrypted_data['sector']}
    ${subdomain}=    Set Variable      ${decrypted_data['subSector']}
    # ${domain}=   Set Variable    ${resp.json()['sector']}
    # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    ${resp2}=   Get Domain Settings    ${domain}  
    Should Be Equal As Strings    ${resp.status_code}    200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${check}  ${resp2.json()['multipleLocation']}
    Exit For Loop IF     "${check}"=="True"
    END
    Set Suite Variable  ${a}
    clear_service   ${PUSERNAME99}
    clear_location  ${PUSERNAME99}
    clear_queue  ${PUSERNAME99}
    ${lid22}=  Create Sample Location
    Set Suite Variable  ${lid22}
    ${resp}=   Get Location ById  ${lid22}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  10  ${sTime1}  ${eTime1}  1  5  ${lid22}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}
    
    ${resp}=  Online Checkin In Queue  ${q_id1}  True
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid22}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['noOfOccurance']}  10
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}


JD-TC-CreateQueue-3
    [Documentation]    Create a second queue to the same location with more services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
    Set Suite Variable  ${lic_name}  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END


    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id3}
    ${s_id4}=  Create Sample Service  ${SERVICE5}
    ${s_id5}=  Create Sample Service  ${SERVICE6}
    ${sTime2}=  add_timezone_time  ${tz}  0  35  
    Set Suite Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  1  30  
    Set Suite Variable   ${eTime2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid22}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid22}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id3}
    Should Be Equal As Strings  ${resp.json()['services'][2]['id']}  ${s_id4}
    Should Be Equal As Strings  ${resp.json()['services'][3]['id']}  ${s_id5}

JD-TC-CreateQueue-4
    [Documentation]    Create a second queue to the same location with same time and different services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME99}
    clear_queue  ${PUSERNAME99}

    ${s_id6}=  Create Sample Service  ${SERVICE7}
    ${s_id7}=  Create Sample Service  ${SERVICE8}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid22}  ${s_id6}  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid22}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id6}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id7}

JD-TC-CreateQueue-5
    [Documentation]    Create a  queue in different location with another service and  already existing queue name and time 
    clear_service   ${PUSERNAME99}
    clear_queue  ${PUSERNAME99}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME99}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id8}=  Create Sample Service  ${SERVICE9}

    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid1}  ${s_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id8}

JD-TC-CreateQueue-6
    [Documentation]    Create 2 queues with same time schedule on different days

    ${resp}=  Encrypted Provider Login  ${PUSERNAME133}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END


    clear_service   ${PUSERNAME133}
    clear_queue  ${PUSERNAME133}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  3  5  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${q_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${list11}=  Create List  2  4  6
    ${queue_name1}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name1}  ${recurringtype[1]}  ${list11}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${que_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name1} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1} 

JD-TC-CreateQueue-7
    [Documentation]    Two queue have same time schedul,one queue is enabled and another one disabled
    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END


    clear_service   ${PUSERNAME134}
    clear_queue  ${PUSERNAME134}

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${list}=  Create List  2  4  6
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${s_id3}=  Create Sample Service  ${SERVICE4}
    Set Suite Variable  ${s_id3}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  
    ${sTime3}=  add_timezone_time  ${tz}  0  50
    Set Suite Variable   ${sTime3}
    ${eTime3}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${eTime3}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  
    
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}

    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid1}  ${s_id2}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}

JD-TC-CreateQueue-8
    [Documentation]    create a queue that overlap another two queue 

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+5566782
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_B}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
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
    ${slot}=  Create Dictionary    sTime=${sTime}               eTime=${eTime}
    ${timeSlots}=  Create List   ${slot}
    ${timespec_dict}=  Create Dictionary    recurringType=${recurringtype[1]}  repeatIntervals=${list}   lattitude=${latti}
    ${timespec}=  Create List    ${timespec_dict}
    ${bSchedule}=   Create Dictionary     timespec=${timespec}  timeSlots=${timeSlots}  parkingType=${parking}  open24hours=${24hours} 

    ${baselocation}=  Create Dictionary   place=${city}  longitude=${longi}  lattitude=${latti}  googleMapUrl=${url}  pinCode=${postcode}  address=${address}  parkingType=${parking}  open24hours=${24hours}  bSchedule=${bSchedule}
    ${resp}=      Update Business Profile with kwargs   businessName=${bs}  businessDesc=${desc}  shortName=${companySuffix}  baselocation=${baselocation}  
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
    Set Test Variable    ${spec1}     ${resp.json()[0]['displayName']}   
    Set Test Variable    ${spec2}     ${resp.json()[1]['displayName']}   

    ${spec}=  Create List    ${spec1}   ${spec2}

    ${resp}=  Update Business Profile with kwargs  specialization=${spec}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME_B}
    clear_location  ${PUSERNAME_B}
    clear_queue  ${PUSERNAME_B}
    
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id2}=  Create Sample Service  ${SERVICE3}
    Set Suite Variable  ${s_id2}
    ${queue_name}=  FakerLibrary.bs
    ${sTime1}=  add_timezone_time  ${tz}  1  35
    Set Suite Variable  ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}   1  40
    Set Suite Variable  ${eTime1}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    ${resp}=  Disable Queue  ${q_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${q_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}

    ${sTime2}=  add_timezone_time  ${tz}  2  35
    Set Suite Variable  ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  40
    Set Suite Variable  ${eTime2}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id2}  ${resp.json()}
    ${resp}=  Disable Queue  ${q_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${q_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[1]}

    ${resp}=  Get Queues
    Log  ${resp.json()}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid1}
    Should Be Equal As Strings  ${resp.json()['id']}  ${q_id3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}

JD-TC-CreateQueue-9
    [Documentation]    Create a queue in different location with overlapping time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${sTime}=  add_timezone_time  ${tz}  3  15  
    ${eTime}=  add_timezone_time  ${tz}  3  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking_type}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()}
    ${resp}=  Get Queues
    Log  ${resp.json()}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id3}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid2}
    Should Be Equal As Strings  ${resp.json()['id']}  ${q_id3}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime2}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    
JD-TC-CreateQueue-10
    [Documentation]    Create a queue with field tokenStart in a location of a valid provider then check next queue token start
    ${resp}=  Encrypted Provider Login  ${PUSERNAME138}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME138}
    clear_location  ${PUSERNAME138}
    clear_queue  ${PUSERNAME138}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END
    
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${token_start}=   Random Int  min=5   max=40
    ${queue_capacity}=   Random Int  min=100   max=200
    ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${queue_start}=  Evaluate  ${token_start}+${queue_capacity}
    ${next_queue_start}=  Evaluate  (${queue_start}/100+1)*100
    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    ${eTime5}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime5}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime5}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${next_queue_start}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-CreateQueue-11
    [Documentation]    Create a queue with field tokenStart in a location then create a another queue with another token start then check 2nd queue token start and check third queue token start.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME180}
    clear_location  ${PUSERNAME180}
    clear_queue  ${PUSERNAME180}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${token_start}=   Random Int  min=5   max=40
    ${queue_capacity}=   Random Int  min=5   max=100
    ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    ${eTime5}=  add_timezone_time  ${tz}  1  30  
    ${token_start}=   Random Int  min=45   max=60
    ${queue_capacity}=   Random Int  min=1000   max=2000
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${queue_start}=  Evaluate  ${token_start}+${queue_capacity}
    ${next_queue_start}=  Evaluate  (${queue_start}/100+1)*100
    ${sTime5}=  add_timezone_time  ${tz}  2  15  
    ${eTime5}=  add_timezone_time  ${tz}  2  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  5  ${lid}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime5}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime5}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${next_queue_start}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-CreateQueue-12
    [Documentation]    Create a queue with field tokenStart in a location then create a another queue with same token start of first queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=   Get upgradable license
    # Should Be Equal As Strings    ${resp.status_code}   200
    # ${len}=  Get Length  ${resp.json()}
    # ${len}=  Evaluate  ${len}-1
    # Set Test Variable  ${pkgid}  ${resp.json()[${len}]['pkgId']} 
    # Set Test Variable  ${pkgname}  ${resp.json()[${len}]['pkgName']}

    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pkg_id}=   get_highest_license_pkg
    Log   ${pkg_id}
    Set Suite Variable  ${pkgId}   ${pkg_id[0]}

    IF  '${lic_id}' != '${pkgId}'
        ${resp}=  Change License Package  ${pkgId}
        Should Be Equal As Strings    ${resp.status_code}   200
    END

    clear_service   ${PUSERNAME20}
    clear_location  ${PUSERNAME20}
    clear_queue  ${PUSERNAME20}
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    ${token_start}=   Random Int  min=5   max=40
    ${queue_capacity}=   Random Int  min=5   max=100
    ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${queue_capacity}  ${lid}  ${token_start}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  ${queue_capacity}
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${token_start}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1}

    ${sTime5}=  add_timezone_time  ${tz}  1  15  
    ${eTime5}=  add_timezone_time  ${tz}  1  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue With TokenStart  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime5}  ${eTime5}  1  5  ${lid}  ${token_start}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}

    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime5}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime5}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    Should Be Equal As Strings  ${resp.json()['tokenStarts']}  ${token_start}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-CreateQueue-UH1
    [Documentation]    Create a queue in a location with same queue name
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_EXISTS}"

JD-TC-CreateQueue-UH2
    [Documentation]    Create a queue to the same location with overlapping time
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"


JD-TC-CreateQueue-UH3
    [Documentation]    Create a queue in a location without service details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue without Service  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_SERVICES_REQUIRED}"

JD-TC-CreateQueue-UH4
    [Documentation]    Create a queue in a location without location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${EMPTY}  ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_NOT_FOUND}"

JD-TC-CreateQueue-UH6
    [Documentation]    Create a queue with another providers location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME4}

    ${s_id5}=  Create Sample Service  ${SERVICE3}
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid2}  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-CreateQueue-UH7
    [Documentation]    Create a queue with another providers service  details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME4}

    ${s_id6}=  Create Sample Service  ${SERVICE6}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime2}  1  5  ${lid2}  ${s_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"

JD-TC-CreateQueue-UH8
    [Documentation]    Create a queue with eTime is less than sTime
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${sTime9}=  add_timezone_time  ${tz}  5  15  
    ${eTime9}=  add_timezone_time  ${tz}  4  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  1  5  ${lid1}  ${s_id2}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${STARTTIMECANT_BEGREATERTHANENDTIME}"

JD-TC-CreateQueue-UH9
    [Documentation]    Create a queue with schedule time is lass than service duration
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${description}=  FakerLibrary.sentence
    ${notifytype}    Random Element     ['none','pushMsg','email']
    ${notify}    Random Element     ['True','False'] 
    ${resp}=  Create Service  ${SERVICE1}  ${description}   60  ACTIVE  Waitlist  ${notify}   ${notifytype}  0  500  False  True
    Should Be Equal As Strings  ${resp.status_code}  200    
    Set Suite Variable  ${s_id1}  ${resp.json()} 
    ${sTime9}=  add_timezone_time  ${tz}  4  15  
    ${eTime9}=  add_timezone_time  ${tz}  4  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  queue1  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime9}  ${eTime9}  1  5  ${lid1}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_DURATION_LIMIT_REACHED}" 

JD-TC-CreateQueue-UH10
    [Documentation]    Create 2 queues with same time schedule on same date

    ${resp}=  Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${PUSERNAME134}
    clear_location  ${PUSERNAME134}
    clear_queue  ${PUSERNAME134}

    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${s_id1}=  Create Sample Service  ${SERVICE2}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id1} 

    ${queue_name1}=  FakerLibrary.bs
    ${resp}=  Create Queue  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${QUEUE_SCHEDULE_OVERLAPS_CREATE}"


JD-TC-CreateQueue-13
    [Documentation]  Create Queue for Branch
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-CreateQueue-14
    [Documentation]  Create Queue for User

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

*** Comments ***

#Create Queue with TimeInterval and Appointment
JD-TC-Create Queue with timeinterval-13
    [Documentation]    Create Queue with timeInterval value and Appointment is Enable
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME85}
    clear_location  ${PUSERNAME85}
    clear_queue  ${PUSERNAME85}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[0]}   ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    # Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[0]}
    # Should Be Equal As Strings  ${resp.json()['timeInterval']}  ${timeInterval}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Create Queue with timeinterval-UH1
    [Documentation]    Create Queue with timeInterval value and Appointment is Disable (In this case Can't Expect timeInterval In the Get queue)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME80}
    clear_location  ${PUSERNAME80}
    clear_queue  ${PUSERNAME80}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[1]}   ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    
    ${resp}=  Get Queue ById  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    # Should Be Equal As Strings  ${resp.json()['appointment']}  ${appointment[1]}
    Should Not Contain  ${resp.json()}  ${timeInterval}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Create Queue with timeinterval-UH2
    [Documentation]    Create Queue with timeInterval with Negative value
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}
    clear_queue  ${PUSERNAME120}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}  
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=-10   max=-5
    Set Suite variable  ${timeInterval}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[0]}  ${s_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${TIME_INTERVAL_NOT_NEG}"

JD-TC-Create Queue with timeinterval-UH3
    [Documentation]    Calculation Mode is ML when Create Queue with timeinterval value And Appointment is Enable (In this case Can't Expect timeInterval In the Get queue)
    
    clear_queue  ${PUSERNAME120}   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200  
    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}
    clear_queue  ${PUSERNAME120}  
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}  
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  true  true  true  true  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[0]}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${NOT_ENABLE_APPOINMENT}"
    
    # ${resp}=  Get Queue ById  ${qid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    # Should Be Equal As Strings  ${resp.json()['capacity']}  5
    # Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    # Should Not Contain  ${resp.json()}  ${timeInterval}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}

JD-TC-Create Queue with timeinterval-UH4
    [Documentation]    Calculation Mode is NoCalc when Create Queue with timeinterval value And Appointment is Enable (In this case Can't Expect timeInterval In the Get queue)
    clear_queue  ${PUSERNAME120}    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200 
    clear_service   ${PUSERNAME120}
    clear_location  ${PUSERNAME120}
    clear_queue  ${PUSERNAME120}   
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}    
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']} 
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable  ${s_id1}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${timeInterval}=   Random Int  min=5   max=10
    Set Suite variable  ${timeInterval}
    ${resp}=  Create Queue timeinterval  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  2  5  ${lid}  ${timeInterval}  ${appointment[0]}  ${s_id1}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${NOT_ENABLE_APPOINMENT}"
    # ${resp}=  Get Queue ById  ${qid}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    # Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  ${recurringtype[1]}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['repeatIntervals']}  ${list}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['startDate']}  ${DAY1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['terminator']['endDate']}  ${DAY2}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    # Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    # Should Be Equal As Strings  ${resp.json()['parallelServing']}  2
    # Should Be Equal As Strings  ${resp.json()['capacity']}  5
    # Should Be Equal As Strings  ${resp.json()['queueState']}  ${Qstate[0]}
    # Should Not Contain  ${resp.json()}  ${timeInterval}
    # Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id1}