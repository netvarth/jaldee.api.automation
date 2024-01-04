*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Login
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***
JD-TC-JD S3-1
    [Documentation]   s3 json after creating business profile

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${list}=  Create List  1  2  3 
    Set Suite Variable   ${list}
    ${bs1}=  FakerLibrary.word
    Set Suite Variable   ${bs1}
    ${ph1}=  Evaluate  ${PUSERNAME}+47890
    Set Suite Variable   ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME}+65896
    Set Suite Variable   ${ph2}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  all
    Set Suite Variable  ${ph_nos1} 
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  all  
    Set Suite Variable  ${ph_nos2} 
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs1}.${test_mail}  all
    Set Suite Variable  ${emails1}
    ${bs_name}=  FakerLibrary.bs
    Set Suite Variable   ${bs_name}
    ${bs_desc}=  FakerLibrary.bs
    Set Suite Variable   ${bs_desc}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${latti}=  get_latitude
    Set Suite Variable   ${latti}
    ${longi}=  get_longitude
    Set Suite Variable   ${longi}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable   ${postcode}
    ${address}=  get_address
    Set Suite Variable   ${address}
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  00
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  25  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs_name}  ${bs_desc} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  ${bool[0]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
JD-TC-JD S3-2
    [Documentation]   s3 json after updating business profile

    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${bs2}=  FakerLibrary.word
    Set Suite Variable   ${bs2}
    ${n1}=  FakerLibrary.name
    Set Suite Variable   ${n1}
    ${n2}=  FakerLibrary.name
    Set Suite Variable   ${n2}
    ${n3}=  FakerLibrary.name
    Set Suite Variable   ${n3}
    ${phon1}=  Evaluate  ${PUSERNAME}+70073012
    Set Suite Variable  ${phon1}
    ${phon2}=  Evaluate  ${PUSERNAME}+70073013
    Set Suite Variable  ${phon2}
    # ${phoneno1}=  Phone Numbers  ${n1}  PhoneNo  ${phon1}  all
    # Set Suite Variable  ${phoneno1}
    # ${phoneno2}=  Phone Numbers  ${n2}  PhoneNo  ${phon2}  all  
    # Set Suite Variable  ${phoneno2}
    ${emails1}=  Set Variable  ${P_Email}${bs2}.${test_mail} 
    ${bs_name1}=  FakerLibrary.bs
    Set Suite Variable   ${bs_name1}
    ${bs_desc1}=  FakerLibrary.bs
    Set Suite Variable   ${bs_desc1}
    ${companySuffix1}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix1}
    ${resp}=  Update Business Profile without details  ${bs_name1}  ${bs_desc1} Desc   ${companySuffix1}  ${phon1}  ${emails1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-3
    [Documentation]   s3 json after creating location

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+112249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Create Sample Location 
    Set Suite Variable  ${loc_id}  ${resp}

JD-TC-JD S3-4
    [Documentation]  s3 json after updating location

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+992249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW1}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Create Sample Location 
    Set Suite Variable  ${base_loc_id}  ${resp} 
    ${loc_city}=   get_place
    Set Suite Variable   ${loc_city}
    ${lattitude1}=  get_latitude
    Set Suite Variable   ${lattitude1}
    ${longitude1}=  get_longitude
    Set Suite Variable   ${longitude1}
    ${comp_suffix1}=  FakerLibrary.companySuffix
    Set Suite Variable   ${comp_suffix1}
    ${pincode1}=  FakerLibrary.postcode
    Set Suite Variable   ${pincode1}
    ${new_addrs}=  get_address
    Set Suite Variable   ${new_addrs}
    ${resp}=  Update Location  ${loc_city}  ${longitude1}  ${lattitude1}  www.${comp_suffix1}.com  ${pincode1}  ${new_addrs}  free  ${bool[1]}  ${base_loc_id} 
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-5
    [Documentation]   s3 json after disabling location

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+882249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW2}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Create Sample Location 
    Set Suite Variable  ${locatid1}  ${resp}
    ${resp}=   Create Sample Location 
    Set Suite Variable  ${locationid1}  ${resp}
    ${resp}=  Disable Location  ${locationid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-6
    [Documentation]   s3 json after enabling location

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+772250
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW3}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}    Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${locatid2}  ${resp.json()}
    ${resp}=  Create Sample Location 
    Set Suite Variable  ${locationid2}  ${resp} 
    ${resp}=  Get Location ById  ${locationid2}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Disable Location  ${locationid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${resp}=  Get Location ById  ${locationid2}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    ${resp}=  Enable Location  ${locationid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

JD-TC-JD S3-7
    [Documentation]   s3 json after creating queue

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+662249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW4}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id1}   ${resp['location_id']}
    Set Suite Variable   ${ser_id1}   ${resp['service_id']}
    Set Suite Variable   ${que_id1}   ${resp['queue_id']}

JD-TC-JD S3-8
    [Documentation]   s3 json after disabling queue

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+552249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW5}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW5}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id2}   ${resp['location_id']}
    Set Suite Variable   ${ser_id2}   ${resp['service_id']}
    Set Suite Variable   ${que_id2}   ${resp['queue_id']}
    ${resp}=  Disable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-9
    [Documentation]   s3 json after enabling queue

    ${f_name}=  FakerLibrary.first_name
    ${l_name}=  FakerLibrary.last_name
    ${resp}=    get_mutilocation_domains
    Log   ${resp}
    Set Test Variable   ${sector}        ${resp[1]['domain']}
    Set Test Variable   ${sub_sector}    ${resp[1]['subdomains'][0]}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+442249
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable   ${PUSERNAME_NEW6}   ${PUSERNAME}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id3}   ${resp['location_id']}
    Set Suite Variable   ${ser_id3}   ${resp['service_id']}
    Set Suite Variable   ${que_id3}   ${resp['queue_id']}
    ${resp}=  Disable Queue  ${que_id3}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Queue  ${que_id3}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-10
    [Documentation]   s3 json after updating queue

    clear_queue      ${PUSERNAME100}
    clear_location   ${PUSERNAME100}
    clear_service    ${PUSERNAME100}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Sample Queue
    Set Suite Variable   ${loc_id4}   ${resp['location_id']}
    Set Suite Variable   ${ser_id4}   ${resp['service_id']}
    Set Suite Variable   ${que_id4}   ${resp['queue_id']}
    ${queue_name}=  FakerLibrary.word
    Set Suite Variable   ${queue_name}
    ${list}=  Create List  5  6  7
    ${parallel}=   Random Int  min=1   max=5
    ${capacity}=   Random Int  min=3   max=10
    ${resp}=  Update Queue  ${que_id4}  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${loc_id4}  ${ser_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-11
    [Documentation]   s3 json after updating Waitlist Settings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${turn_around_time}=   Random Int  min=10   max=30
    Set Suite Variable   ${turn_around_time}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${turn_around_time}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-JD S3-12
    [Documentation]   s3 json after uploading gallery image
    
    # ${resp}=  pyproviderlogin  ${PUSERNAME31}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME31}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # @{resp}=  uploadGalleryImages 
    # Log   ${resp}
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadGalleryImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
*** comment ***         
    sleep  30s
JD-TC-VerifyJD S3-1
    [Documentation]  Verification of get business profile of ${PUSERNAME80}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME80}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${domain1}        ${resp.json()['serviceSector']['domain']}
    Set Suite Variable   ${subdomain1}     ${resp.json()['serviceSubSector']['subDomain']}
    Log   ${resp.json()}
    ${uid}=  get_uid     ${PUSERNAME80}
    Log    ${uid}
    Set Suite Variable  ${uid}
    ${resp}=  requests.get  ${S3_URL}/${uid}/businessProfile.json
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}   businessName=${bs_name}   businessDesc=${bs_desc} Desc    shortName=${companySuffix}   status=${status[0]} 
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}        ${domain1}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sub_domain1}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}             ${name3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}          ${P_Email}${bs1}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}       ${name1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}    ${ph1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}       ${name2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}    ${ph2}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}          ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}        ${postcode}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}        ${address}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}      ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}      ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}   www.${companySuffix}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}    free
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}    ${bool[0]}
    ${resp}=  requests.get  ${S3_URL}/${uid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200

    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longi}  lattitude=${latti}  pinCode=${postcode}  address=${address}  parkingType=free  open24hours=${bool[0]}  status=${status[0]}  googleMapUrl=www.${companySuffix}.com  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3

JD-TC-VerifyJDJD S3-2
    [Documentation]  Verification of get business profile of ${PUSERNAME81}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME81}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${domain2}        ${resp.json()['serviceSector']['domain']}
    Set Suite Variable   ${subdomain2}     ${resp.json()['serviceSubSector']['subDomain']}
    Log   ${resp.json()}
    Verify Response  ${resp}  businessName=${bs_name1}  businessDesc=${bs_desc1} Desc  shortName=${companySuffix1}  status=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}        ${domain2}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${subdomain2}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}             ${n3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}          ${P_Email}${bs2}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}       ${n1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}    ${phon1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}       ${n2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}    ${phon2}

JD-TC-VerifyJDJD S3-3
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Location ById  ${loc_id}
    Log   ${resp.json()}  
    Should Be Equal As Strings         ${resp.status_code}  200
    Set Test Variable  ${place}        ${resp.json()['place']}
    Set Test Variable  ${long}         ${resp.json()['longitude']}
    Set Test Variable  ${latt}         ${resp.json()['lattitude']}
    Set Test Variable  ${pincode}      ${resp.json()['pinCode']}
    Set Test Variable  ${addrs}        ${resp.json()['address']}
    Set Test Variable  ${google_url}   ${resp.json()['googleMapUrl']}
    Set Test Variable  ${stime}        ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}        ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    Set Test Variable  ${open24hr}     ${resp.json()['open24hours']}
    Set Test Variable  ${prk_type}     ${resp.json()['parkingType']}
    ${uid1}=  get_uid     ${PUSERNAME_NEW}
    Log    ${uid1}
    Set Suite Variable  ${uid1}
    ${resp}=  requests.get  ${S3_URL}/${uid1}/location.json
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${place}  longitude=${long}  lattitude=${latt}  pinCode=${pincode}  address=${addrs}  parkingType=${prk_type}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${google_url}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${stime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${etime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][3]}  4
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][4]}  5
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][5]}  6    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][6]}  7

JD-TC-VerifyJDJD S3-4
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW1}   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Location ById  ${base_loc_id}
    Log   ${resp.json()}    
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_stime}   ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Suite Variable    ${loc_etime}   ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    ${uniqueid}=  get_uid     ${PUSERNAME_NEW1}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${loc_city}  longitude=${longitude1}  lattitude=${lattitude1}  pinCode=${pincode1}  address=${new_addrs}  parkingType=free  open24hours=${bool[1]}  status=${status[0]}  googleMapUrl=www.${comp_suffix1}.com  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${loc_stime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${loc_etime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][3]}  4
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][4]}  5
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][5]}  6    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][6]}  7

JD-TC-VerifyJDJD S3-5
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW2}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googleurl}      ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${parkingtype}    ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${open24hr}       ${resp.json()['baseLocation']['open24hours']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}

    ${uniqueid}=  get_uid     ${PUSERNAME_NEW2}
    Log    ${uniqueid}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parkingtype}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${googleurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3

JD-TC-VerifyJDJD S3-6
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW3}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googlemapurl}   ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    Set Test Variable   ${parking_type}   ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${op_hr}          ${resp.json()['baseLocation']['open24hours']}

    ${resp}=  Get Location ById  ${locationid2}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}   
    Should Be Equal As Strings         ${resp.status_code}  200
    Set Test Variable  ${place}        ${resp.json()['place']}
    Set Test Variable  ${long}         ${resp.json()['longitude']}
    Set Test Variable  ${latt}         ${resp.json()['lattitude']}
    Set Test Variable  ${pincode}      ${resp.json()['pinCode']}
    Set Test Variable  ${addrs}        ${resp.json()['address']}
    Set Test Variable  ${google_url}   ${resp.json()['googleMapUrl']}
    Set Test Variable  ${stime}        ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable  ${etime}        ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    Set Test Variable  ${open24hr}     ${resp.json()['open24hours']}
    Set Test Variable  ${prk_type}     ${resp.json()['parkingType']}

    ${uniqueid}=  get_uid     ${PUSERNAME_NEW3}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parking_type}  open24hours=${op_hr}  status=${status[0]}  googleMapUrl=${googlemapurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3

    Verify Response List  ${resp}  1  place=${place}  longitude=${long}  lattitude=${latt}  pinCode=${pincode}  address=${addrs}  parkingType=${prk_type}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${google_url}  baseLocation=${bool[0]}  
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${stime}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${etime}
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][3]}  4
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][4]}  5
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][5]}  6    
    Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals'][6]}  7

JD-TC-VerifyJDJD S3-7
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW4}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googleurl}      ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${parkingtype}    ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${open24hr}       ${resp.json()['baseLocation']['open24hours']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    ${resp}=   Get Queue ById   ${que_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uniqueid}=  get_uid     ${PUSERNAME_NEW4}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parkingtype}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${googleurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3

JD-TC-VerifyJDJD S3-8
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW5}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googleurl}      ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${parkingtype}    ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${open24hr}       ${resp.json()['baseLocation']['open24hours']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    ${uniqueid}=  get_uid     ${PUSERNAME_NEW5}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parkingtype}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${googleurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3
    
JD-TC-VerifyJDJD S3-9
    [Documentation]  Verification of get business profile of ${PUSERNAME_NEW6}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_NEW6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googleurl}      ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${parkingtype}    ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${open24hr}       ${resp.json()['baseLocation']['open24hours']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}
    ${uniqueid}=  get_uid     ${PUSERNAME_NEW6}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Log   ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parkingtype}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${googleurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3

JD-TC-VerifyJDJD S3-10
    [Documentation]  Verification of get business profile of ${PUSERNAME100}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable   ${city}           ${resp.json()['baseLocation']['place']}
    Set Test Variable   ${longitude}      ${resp.json()['baseLocation']['longitude']}
    Set Test Variable   ${lattitude}      ${resp.json()['baseLocation']['lattitude']}
    Set Test Variable   ${postcode}       ${resp.json()['baseLocation']['pinCode']}
    Set Test Variable   ${address}        ${resp.json()['baseLocation']['address']}
    Set Test Variable   ${googleurl}      ${resp.json()['baseLocation']['googleMapUrl']}
    Set Test Variable   ${parkingtype}    ${resp.json()['baseLocation']['parkingType']}
    Set Test Variable   ${open24hr}       ${resp.json()['baseLocation']['open24hours']}
    Set Test Variable   ${starttime}      ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}
    Set Test Variable   ${endtime}        ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}

    ${uniqueid}=  get_uid     ${PUSERNAME100}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/location.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Log   ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  place=${city}  longitude=${longitude}  lattitude=${lattitude}  pinCode=${postcode}  address=${address}  parkingType=${parkingtype}  open24hours=${open24hr}  status=${status[0]}  googleMapUrl=${googleurl}  baseLocation=${bool[1]}  
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${starttime}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${endtime}
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][0]}  1
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][1]}  2    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][2]}  3
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][3]}  4
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][4]}  5
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][5]}  6    
    Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals'][6]}  7

JD-TC-VerifyJDJD S3-11
    [Documentation]  Verification of get business profile of ${PUSERNAME2}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uniqueid}=  get_uid     ${PUSERNAME2}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/settings.json
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${turn_around_time}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  sendNotification=${bool[1]}  maxPartySize=1

JD-TC-VerifyJDJD S3-12
    [Documentation]  Verification of get business profile of ${PUSERNAME3}  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME31}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uniqueid}=  get_uid     ${PUSERNAME31}
    ${resp}=  requests.get  ${S3_URL}/${uniqueid}/gallery.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Set Test Variable  ${gal}  ${resp.json()[0]['thumbUrl']}
    Should Contain   ${gal}  http://ynwtest.youneverwait.com/${uniqueid}/gallery/thumbnail
    Set Test Variable  ${gal}  ${resp.json()[0]['url']}
    Should Contain   ${gal}  http://ynwtest.youneverwait.com/${uniqueid}/gallery/
    Verify Response List  ${resp}  0  caption=firstImage  prefix=gallery  type=.jpg

***Comment*** 
JD-TC-YNW S3-7
    Comment   s3 json after creating services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Service  ${SERVICE1}  Description   30  ${status[0]}  Waitlist  ${bool[1]}  email  45  500  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()} 
    ${resp}=  Create Service  ${SERVICE2}  Description   30  ${status[0]}  Waitlist  ${bool[1]}  email  45  500  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id1}  ${resp.json()}
    Sleep  5s
    ${resp}=  requests.get  ${S3_URL}/${uid}/services.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Verify Response List  ${resp}  0  name=${SERVICE1}  description=Description  serviceDuration=30  notificationType=email   minPrePaymentAmount=45.0  totalAmount=500.0  status=${status[0]}  bType=Waitlist  taxable=${bool[1]}
    Verify Response List  ${resp}  1  name=${SERVICE2}  description=Description  serviceDuration=30  notificationType=email  minPrePaymentAmount=45.0  totalAmount=500.0  bType=Waitlist  status=${status[0]}  taxable=${bool[1]} 

JD-TC-YNW S3-8
    Comment   s3 json after updating services
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service  ${s_id}  ${SERVICE3}  Desc   10  ${status[0]}  Waitlist  ${bool[1]}  none  40  300  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  requests.get  ${S3_URL}/${uid}/services.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Verify Response List  ${resp}  0  name=${SERVICE3}  description=Desc  serviceDuration=10  notificationType=none   minPrePaymentAmount=40.0  totalAmount=300.0  status=${status[0]}  bType=Waitlist  taxable=${bool[0]}
    Verify Response List  ${resp}  1  name=${SERVICE2}  description=Description  serviceDuration=30  notificationType=email  minPrePaymentAmount=45.0  totalAmount=500.0  bType=Waitlist  status=${status[0]}  taxable=${bool[1]} 

JD-TC-YNW S3-9
    Comment   s3 json after disabling service
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable service  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  requests.get  ${S3_URL}/${uid}/services.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  1
    Verify Response List  ${resp}  0  name=${SERVICE3}  description=Desc  serviceDuration=10  notificationType=none   minPrePaymentAmount=40.0  totalAmount=300.0  status=${status[0]}  bType=Waitlist  taxable=${bool[0]}

JD-TC-YNW S3-10
    Comment   s3 json after enabling service
    ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable service  ${s_id1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  5s
    ${resp}=  requests.get  ${S3_URL}/${uid}/services.json
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Integers  ${len}  2
    Verify Response List  ${resp}  0  name=${SERVICE3}  description=Desc  serviceDuration=10  notificationType=none   minPrePaymentAmount=40.0  totalAmount=300.0  status=${status[0]}  bType=Waitlist  taxable=${bool[0]}
    Verify Response List  ${resp}  1  name=${SERVICE2}  description=Description  serviceDuration=30  notificationType=email  minPrePaymentAmount=45.0  totalAmount=500.0  bType=Waitlist  status=${status[0]}  taxable=${bool[1]} 
    