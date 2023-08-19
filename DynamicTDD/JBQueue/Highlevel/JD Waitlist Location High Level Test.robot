*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Location
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${start}  210
${self}    0

*** Test Cases ***
JD-TC-Waitlist Location High Level Test Case-1
	[Documentation]  Checkin to a disabled service

    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME50}
    clear_customer   ${PUSERNAME50}
    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Disable service  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"
    ${resp}=  Enable service   ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
JD-TC-Waitlist Location High Level Test Case-2
    [Documentation]  disable location that location have waitlist

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
    
    FOR   ${a}  IN RANGE   ${start}  ${length}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
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
    clear_location   ${PUSERNAME${a}}
    clear_Providermsg  ${PUSERNAME${a}}
    clear_Consumermsg  ${CUSERNAME6}
    clear_Consumermsg  ${CUSERNAME1}
    clear_consumer_msgs  ${CUSERNAME10}
    clear_provider_msgs  ${PUSERNAME${a}}
    clear_customer   ${PUSERNAME${a}}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    # ${highest_package}=  get_highest_license_pkg
    # Log  ${highest_package}
    # # Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Suite Variable  ${SERVICE1}   ${resp['service_name']}
    # ${city}=   FakerLibrary.state
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}   0  100
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid1}  ${resp.json()}

    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  1  30  
    ${p1queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1   ${capacity}  ${lid1}  ${s_id} 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${qid}  ${resp.json()}
    
    ${resp}=  AddCustomer  ${CUSERNAME10}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId1}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    ${resp}=  Add To Waitlist  ${cId1}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    Comment  Disable Location
    ${resp}=  Disable Location  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-Waitlist Location High Level Test Case-UH1
    [Documentation]  disable queue that queue have waitlist

    ${resp}=  Consumer Login  ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME50}
    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME6}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${qname}  ${resp.json()['name']}
    Comment  Disable queue
    ${resp}=  Disable Queue  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  422
    ${msg}=  Replace String    ${QUEUE_CANNOT_BE_DISABLED}  {}  ${qname}
    Should Be Equal As Strings  "${resp.json()}"  "${msg}"


JD-TC- Waitlist Location High Level Test Case-3
    [Documentation]  create holiday on waitlisted day

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${uname}   ${resp.json()['userName']}

    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME52}
    clear_Providermsg  ${PUSERNAME52}
    clear_Consumermsg  ${CUSERNAME2}
    clear_customer   ${PUSERNAME52}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Test Variable  ${lid1}   ${resp['location_id']}
    Set Suite Variable  ${SERVICE2}   ${resp['service_name']}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME2}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcId2}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${pcId2}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${pcId2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sTime1}   ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}
    Set Test Variable  ${eTime1}   ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}

    ${holi_name}=  FakerLibrary.word
    ${desc}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${resp}=  Create Holiday   ${recurringtype[1]}  ${list}  ${DAY}  ${DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${hId}    ${resp.json()['holidayId']}

    ${resp}=   Activate Holiday  ${boolean[1]}  ${hId}
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200 


JD-TC-Waitlist Location High Level Test Case-4
    [Documentation]  change queue settings that queue have waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}
    
    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Test Variable  ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cId}  ${resp.json()}
    
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Add To Waitlist  ${cId}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${cId}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    ${queue_name}=  FakerLibrary.bs
    ${resp}=  Update Queue  ${qid}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CLEAR_QUEUE_WAITLIST}"

JD-TC-Waitlist Location High Level Test Case-5
    [Documentation]  create family member and waitlist and delete from consumerside and check communication  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME50}
    clear_Providermsg  ${PUSERNAME50}
    clear_Consumermsg  ${CUSERNAME3}
    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Test Variable  ${lid1}   ${resp['location_id']}
    Set Suite Variable  ${SERVICE3}   ${resp['service_name']}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcId3}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${a_id}=  get_acc_id  ${PUSERNAME50}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcId3}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${pcId3}  ${s_id}  ${qid}  ${DAY}  hi  ${bool[1]}  ${mem_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Consumer Login  ${CUSERNAME3}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Cancel Waitlist  ${wid3}  ${a_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Waitlist Location High Level Test Case-6
    [Documentation]  Create business profile not done and location created through create location then check it is a base location
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+4400114
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERNAME_D}    1
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_D}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_D}${\n}
    Set Suite Variable  ${PUSERNAME_D}
    # ${city1}=   get_place
    # Set Suite Variable  ${city1}
    # ${latti1}=  get_latitude
    # Set Suite Variable  ${latti1}
    # ${longi1}=  get_longitude
    # Set Suite Variable  ${longi1}
    # ${postcode1}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode1}
    # ${address1}=  get_address
    # Set Suite Variable  ${address1}
    ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city1}
    Set Suite Variable  ${latti1}
    Set Suite Variable  ${longi1}
    Set Suite Variable  ${postcode1}
    Set Suite Variable  ${address1}
    ${parking_type1}    Random Element   ${parkingType}
    Set Suite Variable  ${parking_type1}
    ${24hours1}    Random Element    ${bool}
    Set Suite Variable  ${24hours1}
    ${sTime1}=  add_timezone_time  ${tz}  0  35  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Suite Variable   ${eTime1}
    ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()}
    ${resp}=  Get Location ById  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  place=${city1}  longitude=${longi1}  lattitude=${latti1}  pinCode=${postcode1}  address=${address1}  parkingType=${parking_type1}  open24hours=${24hours1}  googleMapUrl=www.${city1}.com  status=${status[0]}  baseLocation=${bool[1]}
    Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
    Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

JD-TC-Waitlist Location High Level Test Case-2-Verify

    ${resp}=  ConsumerLogin  ${CUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${consumername}  ${resp.json()['userName']}
    ${cId}=  get_id  ${CUSERNAME10}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    

    Sleep  3s
    ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${a_id00}  ${decrypted_data['id']}
    Set Test Variable  ${pName00}  ${decrypted_data['userName']}
    # Set Test Variable   ${a_id00}   ${resp.json()['id']}
    # Set Test Variable   ${pName00}   ${resp.json()['userName']}
    ${a_id}=  get_acc_id  ${PUSERNAME${a}}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}  ${resp.json()['businessName']}
    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}
    
    ${resp}=   Get Waitlist EncodedId    ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid1}   ${resp.json()}
    
    Set Suite Variable  ${W_encId}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId}  ${W_encId}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${consumername}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${consumername}
    ${defconsumerCancel_msg}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId}  
    ${defconsumerCancel_msg}=  Replace String  ${defconsumerCancel_msg}  [providerMessage]   ${EMPTY}

    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}   0
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   ${defconsumerCancel_msg} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}   ${cId}
    
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${${PUSERNAME${a}}}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  0
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid1}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   ${defconsumerCancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cId}

JD-TC-Waitlist Location High Level Test Case-3-Verify

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${uname}  ${resp.json()['userName']}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME52}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${a_id52}  ${decrypted_data['id']}
    Set Test Variable  ${pName52}  ${decrypted_data['userName']}
    # Set Test Variable   ${a_id52}  ${resp.json()['id']}
    # Set Test Variable   ${pName52}   ${resp.json()['userName']}
    sleep  03s
    ${a_id}=  get_acc_id  ${PUSERNAME52}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}
    ${resp}=  Get Waitlist By Id  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['date']}  ${DAY}
    Should Be Equal As Strings  ${resp.json()['ynwUuid']}  ${wid2}
    Should Be Equal As Strings  ${resp.json()['waitlistStatus']}  ${wl_status[4]}
    
    ${resp}=   Get Waitlist EncodedId    ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid2}   ${resp.json()}
    
    Set Suite Variable  ${W_encId2}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId2}  ${W_encId2}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId2}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defconsumerCancel_msg}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId2}
    ${defconsumerCancel_msg}=  Replace String  ${defconsumerCancel_msg}  [providerMessage]   ${EMPTY}

    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${DATE}=  Convert Date  ${DAY}  result_format=%a, %d %b %Y
    # ${converted_slot}=  convert_slot_12hr  ${slot1} 
    # log    ${converted_slot}
    Set Test Variable  ${cId2}  ${resp.json()['id']}
    # ${DATE}=  Convert Date  ${DAY}  result_format=%d-%m-%Y
    # ${msg}=  Replace String    ${chekIncanceled}  [username]  ${uname}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE2}
    # ${msg}=  Replace String  ${msg}  [date]  ${DATE}
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200 
    Log  ${resp.json()}
    # ${a_id}=  get_acc_id  ${PUSERNAME52}  
    Verify Response List  ${resp}  1  waitlistId=${wid2}  service=${SERVICE2} on ${DATE}  accountId=${a_id}  msg=${defconsumerCancel_msg} 
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${pName52} 
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cId2}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${uname}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Waitlist Location High Level Test Case-5-Verify

    ${resp}=   Consumer Login  ${CUSERNAME3}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${uname1}  ${resp.json()['userName']}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME50}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${a_id50}  ${decrypted_data['id']}
    Set Test Variable  ${pName50}  ${decrypted_data['userName']}
    # Set Test Variable   ${a_id50}  ${resp.json()['id']}
    # Set Test Variable   ${pName50}   ${resp.json()['userName']}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${bname}  ${resp.json()['businessName']}
    ${a_id}=  get_acc_id  ${PUSERNAME50}

    ${resp}=  ListFamilyMemberByProvider  ${pcId3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${firstname1}   ${resp.json()[0]['firstName']}  
    Set Test Variable  ${lastname1}    ${resp.json()[0]['lastName']}  
    Set Test Variable  ${uname}   ${firstname1} ${lastname1}

    ${resp}=   Get Waitlist EncodedId    ${wid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${W_uuid3}   ${resp.json()}
    
    Set Suite Variable  ${W_encId3}  ${resp.json()}

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${confirmAppt_push}=  Set Variable   ${resp.json()['confirmationMessages']['SP_APP']} 
    ${defconsumerCancel_msg}=  Set Variable   ${resp.json()['cancellationMessages']['Consumer_APP']}
    
    ${bookingid}=  Format String  ${bookinglink}  ${W_encId3}  ${W_encId3}
    ${defconfirm_msg}=  Replace String  ${confirmAppt_push}  [consumer]   ${uname}
    ${defconfirm_msg}=  Replace String  ${defconfirm_msg}  [bookingId]   ${W_encId3}

    ${defaultmsg}=  Replace String  ${defconsumerCancel_msg}  [consumer]   ${uname}
    ${defconsumerCancel_msg}=  Replace String  ${defaultmsg}  [bookingId]   ${W_encId3}
    ${defconsumerCancel_msg}=  Replace String  ${defconsumerCancel_msg}  [providerMessage]   ${EMPTY}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}   200   
    ${resp}=   Consumer Login  ${CUSERNAME3}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Test Variable  ${uname}  ${resp.json()['userName']}
    Set Test Variable  ${cId3}  ${resp.json()['id']}

    ${date}=  Convert Date  ${DAY}  result_format=%a, %d %b %Y
    # ${date}=  Convert Date  ${DAY}  result_format=%d-%m-%Y
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    # ${msg}=  Replace String    ${consumerCancel}  [username]  ${uname}
    # ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    # ${msg}=  Replace String  ${msg}  [service]  ${SERVICE3}
    # ${msg}=  Replace String  ${msg}  [date]  ${DATE}
    Verify Response List  ${resp}  1  waitlistId=${wid3}  service=${SERVICE3} on ${DATE}  accountId=${a_id}  msg=${defconsumerCancel_msg}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}  0
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['name']}  ${pName50} 
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}  ${cId3}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['name']}  ${uname1}




*** Comment ***
JD-TC-Waitlist Location High Level Test Case-9
    Comment  disable  location and check queue status
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Disable Queue  ${q2_l1}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Disable Location  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Get Queues 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${q1_l1}
    Should Be Equal As Strings  ${resp.json()[1]['queueState']}  DISABLED
    Should Be Equal As Strings  ${resp.json()[2]['id']}  ${q2_l1}
    Should Be Equal As Strings  ${resp.json()[2]['queueState']}  DISABLED
    Should Be Equal As Strings  ${resp.json()[3]['id']}  ${q3_l1}
    Should Be Equal As Strings  ${resp.json()[3]['queueState']}  DISABLED
    Comment  try to a enable queue 
    ${resp}=  Enable Queue   ${q1_l1}
    Should Be Equal As Strings  ${resp.status_code}  422

JD-TC-Waitlist Location High Level Test Case-6
    Comment  create a watlist for family memeber and check provider ,consumer communications
    clear_consumer_msgs  ${CUSERNAME4}
    clear_provider_msgs  ${PUSERNAME6}
    clear_queue  ${PUSERNAME6}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Create Queue  Evening queue  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}   ${eTime1}  1  5  ${lid1}  ${sId_1}  ${sId_2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q1_l1}  ${resp.json()}
    ${cid}=  get_id  ${CUSERNAME4}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  Suma  M  1980-06-20  female
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${fid}  ${resp.json()}
    clear_provider_msgs  ${PUSERNAME6}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${q1_l1}  ${DAY}  hi  true  ${fid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Waitlist Action  STARTED  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${CurrTime}=  add_timezone_time  ${tz}  0  0
    sleep  3s
    ${resp}=  Waitlist Action  DONE  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${CurrTime1}=  add_timezone_time  ${tz}  0  0
    sleep  3s
    ${resp}=  Get provider communications
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   	Suma M, Your online check-in with Devi Health Care for MakeupHair9090 service has been successful. Your estimated waiting time is 0 mts. We will keep you notified of queue status changes.
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   	Suma M, Your service with Devi Health Care for MakeupHair9090 services, started at ${CurrTime}.
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}   	Suma M, Your MakeupHair9090 service with Devi Health Care has completed at ${CurrTime1}.
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}  ${wid}
    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=   Consumer Login  ${CUSERNAME4}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    sleep  3s
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['msg']}   Suma M, Your online check-in with Devi Health Care for MakeupHair9090 service has been successful. Your estimated waiting time is 0 mts. We will keep you notified of queue status changes.
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[1]['msg']}   	Suma M, Your service with Devi Health Care for MakeupHair9090 services, started at ${CurrTime}.
    Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}  ${wid}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}   	Suma M, Your MakeupHair9090 service with Devi Health Care has completed at ${CurrTime1}.
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}  ${wid}
   

