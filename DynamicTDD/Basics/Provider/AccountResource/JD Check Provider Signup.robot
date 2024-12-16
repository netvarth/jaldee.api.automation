*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ProviderSignup
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
@{Views}  self  all  customersOnly

*** Test Cases ***

JD-TC-Check Provider Signup-1
    [Documentation]    Taking domain and subdomain values ,Then sign up providers in each domain and veryfing all default values
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
    ${parking_type}    Random Element     ['none','free','street','privatelot','valet','paid']
    ${24hours}    Random Element    ['True','False']
    ${recurring_type}    Random Element    ['Weekly','Once']
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ph1}=  Evaluate  ${PUSERNAME}+10000001
    ${ph2}=  Evaluate  ${PUSERNAME}+20000001
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${bs}${P_Email}.${test_mail}  ${views}
    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    Set Test Variable  ${pkgId}  ${licresp.json()[0]['pkgId']}
    Set Test Variable  ${pkgId1}  ${licresp.json()[1]['pkgId']}
    Set Test Variable  ${fname}  ${licresp.json()[1]['pkgName']}
    ${domresp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${len}=  Get Length  ${domresp.json()}
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}+40000001

    FOR  ${domindex}  IN RANGE  ${len}
        Set Test Variable  ${d1}  ${domresp.json()[${domindex}]['domain']}    
        Set Test Variable  ${sd}  ${domresp.json()[${domindex}]['subDomains'][0]['subDomain']} 
        ${PUSERNAME}=  Evaluate  ${PUSERNAME}+1
        ${firstname}=  FakerLibrary.first_name
        ${lastname}=  FakerLibrary.last_name
        ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME}    ${pkgId}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${PUSERNAME}  0
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
        ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  ${parking_type}  ${24hours}  ${recurring_type}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
      
        ${resp}=   Change License Package  ${pkgId1}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200

    END
    ${PUSERNAME}=  Evaluate  ${PUSERNAME}-${len}
    Log  ${PUSERNAME}
    FOR  ${no}  IN RANGE  ${len}
        ${PUSERNAME}=  Evaluate  ${PUSERNAME}+1
        ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        Set Test Variable  ${domain}  ${decrypted_data['sector']}
        Set Test Variable  ${sub_domain}  ${decrypted_data['subSector']}
        # Set Test Variable  ${domain}  ${resp.json()['sector']}
        # Set Test Variable  ${sub_domain}  ${resp.json()['subSector']}
        ${is_corp}=  check_is_corp  ${sub_domain}
        ${business_acc_type}=  Set Variable If   '${is_corp}' == 'True'  ${Business_type[0]}   ${Business_type[1]}
        ${uid}=  get_uid  ${PUSERNAME}
        
        ${resp}=  Get Business Profile
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Desc  shortName=${companySuffix}  status=ACTIVE  createdDate=${DAY1}   verifyLevel=NONE  enableSearch=False  accountLinkedPhNo=${PUSERNAME}  licensePkgID=${pkgId1}  accountType=${business_acc_type}
        Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${domain}
        Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${sub_domain}
        Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
        Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${bs}${P_Email}.${test_mail}
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
        Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  ${parking_type}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  ${24hours}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['startDate']}  ${DAY1}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
        Should Be Equal As Strings  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

        ${resp}=  Get Locations
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city}
        Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address}
        Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode}
        Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi}
        Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti}
        Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
        Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurring_type}
        Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['terminator']['noOfOccurance']}  0  
        Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime}
        Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime}

        ${resp}=  View Waitlist Settings
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${enble_w}  ${resp.json()['enabledWaitlist']}
        Set Test Variable  ${mode}  ${resp.json()['calculationMode']}
        Set Test Variable  ${online}  ${resp.json()['onlineCheckIns']}
        Set Test Variable  ${future}  ${resp.json()['futureDateWaitlist']}
        Set Test Variable  ${trn}  ${resp.json()['trnArndTime']}
        Set Test Variable  ${show_id}  ${resp.json()['showTokenId']}
        Set Test Variable  ${partysize}  ${resp.json()['considerPartySizeForCalculation']}
        # Set Test Variable  ${noti}  ${resp.json()['sendNotification']}
        Set Test Variable  ${period}  ${resp.json()['furtureCheckinPeriod']}
        Set Test Variable  ${filter}  ${resp.json()['filterByDept']}
        Log  ${S3_URL}

        # sleep  4s 

        # ${resp}=  requests.get  ${S3_URL}/${uid}/settings.json
        # Log  ${resp.content}
        # Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response  ${resp}  enabledWaitlist=${enble_w}  calculationMode=${mode}  onlineCheckIns=${online}  futureDateWaitlist=${future}  trnArndTime=${trn}  showTokenId=${show_id}  considerPartySizeForCalculation=${partysize}  furtureCheckinPeriod=${period}  filterByDept=${filter}
    # sendNotification=${noti} 

        # sleep  2s  
        
        ${resp}=  Get Features  ${sub_domain}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${service_name}  ${resp.json()['features']['defaultServices'][0]['service']}
        #Set Test Variable  ${service_amt}  ${resp.json()['features']['defaultServices'][0]['amount']}
        Set Test Variable  ${service_duration}  ${resp.json()['features']['defaultServices'][0]['duration']}
        Set Test Variable  ${service_status}  ${resp.json()['features']['defaultServices'][0]['status']}        
        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response List   ${resp}  0  name=${service_name}  status=${service_status}  serviceDuration=${service_duration}
        #Verify Response List   ${resp}  0  totalAmount=${service_amt}

        ${resp}=   Get Active License
        Should Be Equal As Strings    ${resp.status_code}   200
        Should Be Equal As Strings  ${resp.json()['accountLicense']['licPkgOrAddonId']}  ${pkgId1}
        Should Be Equal As Strings  ${resp.json()['accountLicense']['base']}  True
        Should Be Equal As Strings  ${resp.json()['accountLicense']['licenseTransactionType']}  Upgrade
        Should Be Equal As Strings  ${resp.json()['accountLicense']['type']}  Production
        Should Be Equal As Strings  ${resp.json()['accountLicense']['status']}  Active
        Should Be Equal As Strings  ${resp.json()['accountLicense']['name']}  ${fname}
        
        ${EMPTY_List}=  Create List  @{EMPTY}

        ${resp}=  Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}  

        ${is_multi_location}=  check_is_multilocation  ${domain}
        ${lid}=  Run keyword If  '${is_corp}' == 'False' and '${is_multi_location}' == 'True'  Create Sample Location
        sleep   01s
        ${resp}=  Get Queues
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()}   ${EMPTY_List}


        # Should Be Equal As Strings  ${resp.json()[0]['name']}  Time Window 1
        # Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['recurringType']}  ${recurring_type}
        # Should Be Equal As Strings  ${resp.json()[0]['queueSchedule']['startDate']}  ${DAY1}
        # Should Be Equal As Strings  ${resp.json()[0]['parallelServing']}  1
        # Should Be Equal As Strings  ${resp.json()[0]['capacity']}  20

    END




