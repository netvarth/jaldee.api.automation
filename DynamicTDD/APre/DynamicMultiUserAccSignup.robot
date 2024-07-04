*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Branch Signup
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Library           FakerLibrary

*** Variables ***
${nods}  0
@{Views}  self  all  customersOnly
# ${defaultCount}  80
${PUSER}      ${PUSERNAME}


*** Test Cases ***

Remove Files
   
    # Remove File   ${EXECDIR}/TDD/varfiles/musers.py
    # Create File   ${EXECDIR}/TDD/varfiles/musers.py

    # Remove File   ${EXECDIR}/TDD/varfiles/hl_musers.py
    # Create File   ${EXECDIR}/TDD/varfiles/hl_musers.py

    Remove File   ${EXECDIR}/TDD/varfiles/providers.py
    Create File   ${EXECDIR}/TDD/varfiles/providers.py

    Remove File   ${EXECDIR}/TDD/varfiles/hl_providers.py
    Create File   ${EXECDIR}/TDD/varfiles/hl_providers.py

JD-TC-Branch_Signup-1
    [Documentation]    Create a provider with all valid attributes
    Set Global Variable  ${US}  0
    Set Global Variable  ${BR}  ${0}
    
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    FOR  ${index}  IN RANGE  ${len}
        ${sublen}=  Get Length  ${domresp.json()[${index}]['subDomains']}
        ${nods}=  Evaluate  ${nods}+${sublen}
    END

    # ${corp_resp}=   get_iscorp_subdomains  1
    # ${iscorpnods}=   Get Length  ${corp_resp}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()} 
    ${totnods}=   Evaluate  ${liclen}*${nods}
    # ${totiscorpnods}=   Evaluate  ${liclen}*${iscorpnods}


    # ${usercount}=  Set Variable If  ${provider_count}>${defaultCount}  ${provider_count}   ${defaultCount} 
    ${count}=  Set Variable If  ${provider_count}>${totnods}  ${provider_count}   ${totnods}
    Set Global Variable  ${count}   
    #${newrange}=  Set Variable If  ${newlen}>${liclen}  ${newlen}   ${liclen}  
    # ${licresp}=   Get Licensable Packages
    # Should Be Equal As Strings   ${licresp.status_code}   200
    # ${liclen}=  Get Length  ${licresp.json()}  
    ${newlen}=  Evaluate  ${count}/(${liclen}*${nods})
    ${newlen}=  Set Variable If  ${newlen}<1  ${newlen+1}   ${newlen}
    Log   ${newlen}
    FOR  ${licindex}  IN RANGE  ${newlen}
        Exit For Loop If    '${US}' == '${count}'
        License Loop  ${liclen}  ${licresp}
    END
    Log Many  ${PUSER}  ${count}  ${US}

    ${count}=  Set Variable If  ${count}==${totnods}  ${totnods}   ${provider_count}
    Log  ${count}

    Log  \n${count} multiuser accounts signed up   console=yes

    ${PUSER}=  Evaluate  ${PUSER}-${count}
    
    sleep  01s
    FOR  ${no}  IN RANGE  ${count}
        ${PUSER}=  Evaluate  ${PUSER}+1
        ${resp}=  Encrypted Provider Login  ${PUSER}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${sub_domain}  ${decrypted_data['subSector']}
        # Set Test Variable  ${sub_domain}  ${resp.json()['subSector']}
        ${fname}=  Set Variable  ${decrypted_data['firstName']}
        ${lname}=  Set Variable  ${decrypted_data['lastName']}

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}

        ${resp}=  View Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[1]}

        #${resp}=  Get Queues
        #Log  ${resp.json()}
        #Should Be Equal As Strings  ${resp.status_code}  200
        #Should Be Equal As Strings  ${resp.json()[0]['name']}  Time Window 1
        #Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  Weekly
        #Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['startDate']}  ${DAY1}
        #Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime}
        #Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime}

        ${resp}=  Get Features  ${sub_domain}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${service_name}  ${resp.json()['features']['defaultServices'][0]['service']}
        #Set Test Variable  ${service_amt}  ${resp.json()['features']['defaultServices'][0]['amount']}
        Set Test Variable  ${service_duration}  ${resp.json()['features']['defaultServices'][0]['duration']}
        Set Test Variable  ${service_status}  ${resp.json()['features']['defaultServices'][0]['status']}  

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Verify Response List   ${resp}  0  name=${service_name}  status=${service_status}  serviceDuration=${service_duration}
        #Verify Response List   ${resp}  0  totalAmount=${service_amt}

        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
        Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}

        ${resp}=  Get Order Settings by account id
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${fname}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${lname}
        Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${PUSER}
    END

     
    
*** Keywords ***
SignUp Account
    [Arguments]    ${di}  ${d}  ${domresp}  ${pkgId}  ${pkg_name}
    ${sublen}=  Get Length  ${domresp.json()[${di}]['subDomains']}
    FOR  ${subindex}  IN RANGE  ${sublen} 
        Exit For Loop If    '${US}' == '${count}'
        Set Test Variable  ${sd}  ${domresp.json()[${di}]['subDomains'][${subindex}]['subDomain']}  
        ${is_corp}=  check_is_corp  ${sd}
        Log  ${is_corp}
        Continue For Loop If  '${is_corp}' == 'False'
         ${PUSER}=  Evaluate   ${PUSER}+1
        Set Global Variable   ${PUSER}
        ${firstname}=  FakerLibrary.name
        ${lastname}=  FakerLibrary.last_name
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d}  ${sd}   ${PUSER}  ${pkgId}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation   ${PUSER}  0
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential   ${PUSER}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSER}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        # ${is_corp}=  check_is_corp  ${sd}
        # Log  ${is_corp}
        # Run Keyword If  '${is_corp}' == 'True'  Append To File  ${EXECDIR}/TDD/varfiles/branches.py  BUSERNAME${BC}= ${PUSER}${\n}
        # Run Keyword If  '${is_corp}' == 'False'  Append To File  ${EXECDIR}/TDD/varfiles/providers.py  PUSERNAME${PC}=${PUSERNAME}${\n}
        # Append To File  ${EXECDIR}/TDD/varfiles/branches.py  BUSERNAME${US}= ${PUSER}${\n}
        # Append To File  ${EXECDIR}/TDD/varfiles/musers.py  PUSERNAME${US}= ${PUSER}${\n}
        # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt   ${PUSER}${\n}
        ${highest_pkg}=  get_highest_license_pkg
        # Run Keyword If  '${pkgId}' == '${highest_pkg[0]}'   Append To File  ${EXECDIR}/TDD/varfiles/branches_highestlic.py  BHUSERNAME${BR}= ${PUSER}${\n}
        IF  '${pkgId}' == '${highest_pkg[0]}'
        # Append To File  ${EXECDIR}/TDD/varfiles/branches_highestlic.py  BHUSERNAME${BR}= ${PUSER}${\n}
        # Append To File  ${EXECDIR}/TDD/varfiles/hl_musers.py  HLPUSERNAME${BR}= ${PUSER}${\n}
        Append To File  ${EXECDIR}/TDD/varfiles/hl_providers.py  HLPUSERNAME${BR}= ${PUSER}${\n}
        END
        ${BR} =	Set Variable If	 '${pkgId}' == '${highest_pkg[0]}'	${BR+1}	 ${BR}
        Set Global Variable  ${BR}

        sleep  01s

        ${resp}=  Encrypted Provider Login   ${PUSER}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Suite Variable  ${pid}  ${decrypted_data['id']}

        # Append To File  ${EXECDIR}/TDD/varfiles/musers.py  PUSERNAME${US}= ${PUSER}${\n}
        Append To File  ${EXECDIR}/TDD/varfiles/providers.py  PUSERNAME${US}=${PUSER}${\n}
        Append To File  ${EXECDIR}/TDD/varfiles/aprenumbers.txt  ${PUSER}${\n}
        
        Set Test Variable  ${email_id}  ${P_Email}${PUSER}.${test_mail}
        ${resp}=  Update Email   ${pid}   ${firstname}   ${lastname}   ${email_id}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Business Profile
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  status=INCOMPLETE
        ${US} =  Evaluate  ${US}+1
        Set Global Variable  ${US} 
        # ${DAY1}=  get_date
        # Set Suite Variable  ${DAY1}  ${DAY1}
        ${list}=  Create List  1  2  3  4  5  6  7
        Set Suite Variable  ${list}  ${list}
        ${ph1}=  Evaluate   ${PUSER}+1000000000
        ${ph2}=  Evaluate   ${PUSER}+2000000000
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
        ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${P_Email}${US}.${test_mail}  ${views}
        ${bs}=  FakerLibrary.bs
        ${companySuffix}=  FakerLibrary.companySuffix
        # ${city}=   get_place
        # ${latti}=  get_latitude
        # ${longi}=  get_longitude
        # ${latti}  ${longi}=  get_lat_long
        # ${postcode}=  FakerLibrary.postcode
        # ${address}=  get_address
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${DAY1}=  get_date_by_timezone  ${tz}
        ${Time}=  db.get_time_by_timezone   ${tz}
        ${sTime}=  add_timezone_time  ${tz}  0  15  
        Set Suite Variable   ${sTime}  ${sTime}
        ${eTime}=  add_timezone_time  ${tz}  0  45  
        Set Suite Variable   ${eTime}  ${eTime}

        #${resp}=  Create Business Profile  ${bs}  ${bs} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
        #Log  ${resp.json()}
        #Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Business Profile
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}
        Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}  licence=${pkg_name}  verifyLevel=NONE  enableSearch=False  accountLinkedPhNo=${PUSER}  licensePkgID=${pkgId}  #accountType=INDEPENDENT_SP
        Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${d}
        Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sd}
        Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
        Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${P_Email}${US}.${test_mail}
        Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
        Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
        Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
        Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}  ${postcode}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${companySuffix}.com
        Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  free
        Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  True
        Should Be Equal As Strings  ${resp.json()['baseLocation']['status']}  ACTIVE
        #Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
        #Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
        #Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

        #${resp}=  pyproviderlogin  ${PUSER}  ${PASSWORD}
       # Should Be Equal As Strings  ${resp}  200      
        #@{resp}=  uploadLogoImages 
        #Should Be Equal As Strings  ${resp[1]}  200
        #${resp}=  Get GalleryOrlogo image  logo
        #Should Be Equal As Strings  ${resp.status_code}  200
       # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

        ${fields}=   Get subDomain level Fields  ${d}  ${sd}
        Log  ${fields.json()}
        Should Be Equal As Strings    ${fields.status_code}   200
        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${resp}=  Get specializations Sub Domain  ${d}  ${sd}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${spec}=  get_Specializations  ${resp.json()}
        ${resp}=  Update Specialization  ${spec}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${resp}=  View Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['enabledWaitlist']}  ${bool[0]}
        ${resp}=  Enable Waitlist
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
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
        ${resp}=   Get Accountsettings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[0]}
        ${resp}=   Get Appointment Settings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        ${result}=  Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
        Log   ${result.json()}
        Should Be Equal As Strings  ${result.status_code}  200
        ${resp}=   Get Accountsettings
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()['appointment']}   ${bool[1]}

        enquiryStatus  ${account_id}
        leadStatus  ${account_id}

          
    END

Domain Loop
    [Arguments]  ${pkgId}  ${pkg_name}
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    #Set Global Variable  ${US}  0
    FOR  ${domindex}  IN RANGE  ${len}
        Exit For Loop If    '${US}' == '${count}' 
        Set Test Variable  ${d1}  ${resp.json()[${domindex}]['domain']}    
        SignUp Account  ${domindex}  ${d1}  ${resp}  ${pkgId}  ${pkg_name}
    END
License Loop
   [Arguments]  ${liclen}  ${licresp}
    FOR  ${licindex}  IN RANGE  ${liclen}
        Exit For Loop If    '${US}' == '${count}'
        Set Test Variable  ${pkgId}  ${licresp.json()[${licindex}]['pkgId']}
        Set Test Variable  ${pkg_name}  ${licresp.json()[${licindex}]['displayName']}
        Domain Loop  ${pkgId}  ${pkg_name}
    END