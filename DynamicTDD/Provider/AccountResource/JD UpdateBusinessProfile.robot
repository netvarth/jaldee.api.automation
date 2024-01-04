** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
...               AND   Remove File  cookies.txt
Force Tags        BusinessProfile
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
@{Views}  self  all  customersOnly

*** Test Cases ***

JD-TC-UpdateBusinessProfile-1
    [Documentation]  Update  business profile for a valid provider without schedule
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${d}  ${resp.json()['sector']}
    Set Suite Variable  ${sd}  ${resp.json()['subSector']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${ph1}=  Evaluate  ${PUSERNAME}+11001
    Set Suite Variable  ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME}+11002
    Set Suite Variable  ${ph2}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    Set Suite Variable  ${name1}
    ${name2}=  FakerLibrary.name
    Set Suite Variable  ${name2}
    ${name3}=  FakerLibrary.name
    Set Suite Variable  ${name3}
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    Set Suite Variable  ${ph_nos1}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    Set Suite Variable  ${ph_nos2}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs}.${test_mail}  ${views}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    ${resp}=  Update Business Profile without schedule   ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  free  True  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${createdDAY}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${P_Email}${bs}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}   ${address}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}  ${postcode}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  free
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  True

JD-TC-UpdateBusinessProfile-2
    [Documentation]  Update  business profile with no details of provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

    ${resp}=  Update Business Profile without phone and email  ${EMPTY}  ${EMPTY}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${EMPTY}  businessDesc=${EMPTY}  shortName=${EMPTY}  status=ACTIVE  createdDate=${createdDAY}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
    Should Be Equal As Strings  ${resp.json()['emails']}  None
    Should Be Equal As Strings  ${resp.json()['phoneNumbers']}  None


JD-TC-UpdateBusinessProfile-3
    [Documentation]  Update  business profile with no base location details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${emails1}=  Set Variable  ${P_Email}${bs}.${test_mail}  
    ${resp}=  Update Business Profile without details  ${bs}  ${bs}Desc   ${companySuffix}  ${ph1}   ${emails1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${createdDAY}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
    Should Be Equal As Strings  ${resp.json()['emails']}  ${P_Email}${bs}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers']}  ${ph1}
   
JD-TC-UpdateBusinessProfile-4
    [Documentation]  Update  business profile with location schedule details(Provider has no business profile)
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${len}=  Evaluate  ${len}-1
    Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
    Set Suite Variable  ${sd1}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+662266
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERNAME_B}    ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
    Set Suite Variable  ${PUSERNAME_B}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${resp}=  Update Business Profile with location only   ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  free  True  ${postcode}  ${address}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()['baseLocation']['id']}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${sTime}=  add_timezone_time  ${tz}  1  0  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  1  50  
    Set Suite Variable   ${eTime}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs}.${test_mail}  ${views}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd1}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  free
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  True
    Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

JD-TC-UpdateBusinessProfile-5
    [Documentation]  Update  business profile with alredy existing location schedule with different details
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs}.${test_mail}  ${views}
    ${sTime1}=  add_timezone_time  ${tz}  2  0  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  50  
    Set Suite Variable   ${eTime1}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  paid  false  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd1}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${P_Email}${bs}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  paid
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  False
    Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
 
JD-TC-UpdateBusinessProfile-6
    [Documentation]  Update  business profile with alredy existing location schedule with different details when queue waitlisted
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_customer   ${PUSERNAME_B}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  pyproviderlogin  ${PUSERNAME_B}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    # @{resp}=  uploadLogoImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Queues
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Sample Queue
    Set Suite Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable  ${sid}   ${resp['service_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  AddCustomer  ${CUSERNAME1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}   ${cnote}   ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=arrived
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${city}=   FakerLibrary.state
    Set Suite Variable  ${city}
    ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable  ${companySuffix}
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs}.${test_mail}  ${views}
    Set Suite Variable  ${emails1}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  paid  false  Monthly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs}Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d1}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd1}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${P_Email}${bs}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
    Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  paid
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  False
    Should Be Equal As Strings  ${resp.json()['baseLocation']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['recurringType']}  Monthly
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}
    
JD-TC-UpdateBusinessProfile-UH1
    [Documentation]  Update  business profile without login
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  paid  false  Monthly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
      
JD-TC-UpdateBusinessProfile-UH2
    [Documentation]  Update  business profile using comsumer login
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs}Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${bs}.com  paid  false  Monthly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${lid}
    Should Be Equal As Strings  ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

