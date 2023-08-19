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
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${SERVICE3}  Face Makeup  
${SERVICE4}  Facial

*** Test Cases ***

JD-TC-Is AvailableQueueNow ByProviderId-1
    [Documentation]  Get Queue AvailableNow By ProviderId
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}

    ${firstname_A}=  FakerLibrary.first_name
    ${lastname_A}=  FakerLibrary.last_name
    ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+778805578
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E1}${\n}
    Set Suite Variable  ${MUSERNAME_E1}
    ${id}=  get_id  ${MUSERNAME_E1}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1000880000
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2000880000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.ynwtest@netvarth.com  ${views}
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
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  subtract_timezone_time  ${tz}  3  00
    Set Suite Variable  ${BsTime30}  ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  4  30  
    Set Suite Variable  ${BeTime30}  ${eTime}
    ${resp}=  Update Business Profile with schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

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

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['enabledWaitlist']}==${bool[0]}
        ${resp1}=  Enable Waitlist
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp1}=  Toggle Department Enable
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200

    END
    sleep   01s

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    

    # ${resp}=  View Waitlist Settings
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # IF  ${resp.json()['filterByDept']}==${bool[0]}
    #     ${resp}=  Toggle Department Enable
    #     Log  ${resp.content}
    #     Should Be Equal As Strings  ${resp.status_code}  200

    # END
    
    # sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${ph1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${ph1}  ${countryCodes[1]}  ${ph1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['subdomain']}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    
    # ${lid}=  Create Sample Location
    # Set Suite Variable  ${lid}
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${lid}   ${resp.json()[0]['id']}
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  3  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}
  
    ${resp}=  Get Accountsettings  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response   ${resp}    waitlist=${bool[1]}   appointment=${bool[0]}

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}
    Verify Response    ${resp}   holiday=${bool[0]}
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}
    
  

JD-TC-Is AvailableQueueNow ByProviderId-2
    [Documentation]    AvailableNow is False, when vacation create
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}

    # clear_service   ${MUSERNAME_E1}
    # clear_location  ${MUSERNAME_E1}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[${pos}]['subdomainId']}
            Set Suite Variable  ${userSubDomain}  ${iscorp_subdomains[${pos}]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END
  
    ${numbers}=     Random Int   min=501   max=7000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME_E1}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  pincode=${pin}  deptId=${dep_id}  subdomain=${userSubDomain}
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id}  ${u_id1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}
  
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}


    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${desc}=    FakerLibrary.name
    Set Test Variable      ${desc}
    ${resp}=  Create Vacation   ${desc}  ${u_id1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${CUR_DAY}  ${EMPTY}  ${sTime1}  ${eTime1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${v1_id}    ${resp.json()['holidayId']}
    
    ${resp}=   Get Vacation    ${u_id1}
    Log  ${resp.json()}
    Set Suite Variable  ${v_id}  ${resp.json()[0]['id']}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response List   ${resp}   0  id=${v_id}   description=${desc} 
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['recurringType']}                     ${recurringtype[1]}
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['repeatIntervals']}                   ${list}  
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['startDate']}                         ${CUR_DAY}
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['terminator']['endDate']}             ${CUR_DAY}  
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['sTime']}             ${start_time}  
    # Should Be Equal As Strings   ${resp.json()[0]['holidaySchedule']['timeSlots'][0]['eTime']}             ${end_time}
       

    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[1]}
    

JD-TC-Is AvailableQueueNow ByProviderId-3
    [Documentation]    AvailableNow is False, when queue is Future timeslot
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # clear_service   ${MUSERNAME_E1}
    # clear_location  ${MUSERNAME_E1}
  
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id1}  ${resp.json()}
    
    ${numbers}=     Random Int   min=501   max=7000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME_E1}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id1}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com   deptId=${dep_id1}  subdomain=${userSubDomain}
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id1}  ${u_id1}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    Set Suite Variable   ${parallel}

    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}
  
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
   

JD-TC-Is AvailableQueueNow ByProviderId-4
    [Documentation]    AvailableNow is False, when queue is a Non working day
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME68}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${MUSERNAME68}
    clear_location  ${MUSERNAME68}
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp1}=   Run Keyword If   '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'   Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    # ${resp}=   Change License Package  ${highest_package[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    # sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id2}  ${resp.json()}

     ${numbers}=     Random Int   min=701   max=9000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id2}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id}  subdomain=${userSubDomain}
    
    ${lid}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List    1  2  3  4  5  6

    ${curr_weekday}=  get_timezone_weekday  ${tz}
    ${daygap}=  Evaluate  7-${curr_weekday}
    ${DAY1}=  db.add_timezone_date  ${tz}  ${daygap}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  60      
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id2}  ${u_id1}
    ${queue_name}=  FakerLibrary.name
     ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}  ${resp.json()}
  
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
   
JD-TC-Is AvailableQueueNow ByProviderId-5
    [Documentation]    check Queue is AvailableNow By ProviderId with location disable
    ${resp}=  Encrypted Provider Login  ${MUSERNAME69}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${subdomain}  ${resp.json()['subSector']}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
            Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    clear_service   ${MUSERNAME69}
    # clear_location  ${MUSERNAME69}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp1}=   Run Keyword If   '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'   Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    # Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    # sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id3}  ${resp.json()}

    ${numbers}=     Random Int   min=701   max=9000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id3}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
#     Set Suite Variable  ${sub_domain_id1}  ${resp.json()['subdomain']}
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}   mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id3}  
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List    1  2  3  4  5  6

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  60      
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id3}  ${u_id1}
    ${queue_name}=  FakerLibrary.name
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid1}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}  ${resp.json()}
  
    ${resp}=  Disable Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  status=INACTIVE

    ${resp}=    Is Available Queue Now ByProviderId    ${u_id1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
    

    ${resp}=  Enable Location  ${lid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Location ById  ${lid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  status=ACTIVE


JD-TC-Is AvailableQueueNow ByProviderId-6
    [Documentation]   check  Queue is AvailableNow By ProviderId with queue disable
    ${resp}=  Encrypted Provider Login  ${MUSERNAME69}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${subdomain}  ${resp.json()['subSector']}

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    ${dlen}=  Get Length  ${iscorp_subdomains}
    FOR  ${pos}  IN RANGE  ${dlen}  
        IF  '${iscorp_subdomains[${pos}]['subdomains']}' == '${subdomain}'
            Set Test Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
            Set Test Variable  ${userSubDomain}  ${iscorp_subdomains[0]['userSubDomain']}
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END

    clear_service   ${MUSERNAME69}
    clear_location  ${MUSERNAME69}
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp1}=   Run Keyword If   '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'   Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
    
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
#     Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id4}  ${resp.json()}

     ${numbers}=     Random Int   min=701   max=9000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id4}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id4}  
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List    1  2  3  4  5  6

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  60      
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id4}  ${u_id1}
    ${queue_name}=  FakerLibrary.name
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid1}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}  ${resp.json()}
  
    ${resp}=  Disable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=DISABLED 
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
   

    ${resp}=  Enable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=ENABLED
  
JD-TC-Is AvailableQueueNow ByProviderId-7
    [Documentation]    check Queue is AvailableNow By ProviderId with multile queues and one queue is disabled
    ${resp}=  Encrypted Provider Login  ${MUSERNAME69}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_service   ${MUSERNAME69}
    clear_location  ${MUSERNAME69}
    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp1}=   Run Keyword If   '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'   Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id3}  ${resp.json()}

     ${numbers}=     Random Int   min=701   max=9000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id3}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id3} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${list}=  Create List    1  2  3  4  5  6

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  60      
    ${s_id}=  Create Sample Service For User  ${SERVICE1}  ${dep_id3}  ${u_id1}
    ${queue_name}=  FakerLibrary.name
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid1}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}  ${resp.json()}

    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}   1  60    
    ${s_id}=  Create Sample Service For User  ${SERVICE2}  ${dep_id3}  ${u_id1}
    ${queue_name}=  FakerLibrary.name
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  5  ${lid1}  ${u_id1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id3}  ${resp.json()}

    ${resp}=  Disable Queue  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${que_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  queueState=DISABLED 
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[1]}
    Verify Response    ${resp}   holiday=${bool[0]}
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}
    

JD-TC-Is AvailableQueueNow ByProviderId-8
    [Documentation]    check Queue is AvailableNow By ProviderId with no queues are there 
    ${resp}=  Encrypted Provider Login  ${MUSERNAME69}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue   ${MUSERNAME69}
    clear_location  ${MUSERNAME69}

    ${highest_package}=  get_highest_license_pkg
    Log  ${highest_package}
    Set Suite variable  ${lic2}  ${highest_package[0]}
    # ${resp1}=   Run Keyword If   '${resp.json()['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'   Change License Package  ${highest_package[0]}
    # Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    # Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    IF  '${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}' != '${lic2}'
        ${resp1}=   Change License Package  ${highest_package[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END
   
    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${dep_id3}  ${resp.json()}

    ${numbers}=     Random Int   min=701   max=9000
    ${PUSERPH0}=  Evaluate  ${MUSERNAME}+${numbers}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERPH0}  ${dep_id3}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${PUSERPH0}  ${countryCodes[1]}  ${PUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id1}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERPH0}.ynwtest@netvarth.com  city=${city}  state=${state}  deptId=${dep_id3}  
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['whatsAppNum']['countryCode']}      ${countryCodes[1]}
    Should Be Equal As Strings  ${resp.json()['telegramNum']['number']}           ${PUSERPH0} 
    Should Be Equal As Strings  ${resp.json()['telegramNum']['countryCode']}      ${countryCodes[1]}
       
    ${lid1}=  Create Sample Location
    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    # ${list}=  Create List    1  2  3  4  5  6
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id1}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
  


JD-TC-Is AvailableQueueNow ByProviderId-UH1
    [Documentation]  Get queue AvailableNow schedule without Provider login 
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id}
    Log    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"


JD-TC-Is AvailableQueueNow ByProviderId-UH2
    [Documentation]   Another  Provider login 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME6}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get User  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Is Available Queue Now ByProviderId    ${u_id}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response        ${resp}   availableNow=${bool[0]}
    Verify Response    ${resp}   holiday=${bool[0]}
    # Should Be Equal As Strings    ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"   "user not found this account"

JD-TC-Is AvailableQueueNow ByProviderId-UH3

    [Documentation]  Get queue AvailableNow schedule with consumer login
    
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Is Available Queue Now ByProviderId    ${u_id}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
