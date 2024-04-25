*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  Waitlist
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
@{Views}  self  all  customersOnly
${CAUSERNAME}              admin.support@jaldee.com
${PASSWORD}               Netvarth12
${NEWPASSWORD}            Jaldee12
${SPASSWORD}              Netvarth1
${test_mail}              test@jaldee.com
${count}  ${1}

*** Test Cases ***

JD-TC-Provider_Signup-1
    [Documentation]   Provider Signup in Random Domain 

    ${data_dir_path}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}data/
    ${data_file}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
    ${var_dir_path}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/
    ${var_file}=    Set Variable    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

    IF  ${{os.path.exists($data_dir_path)}} is False
        Create Directory   ${data_dir_path}
    END
    IF  ${{os.path.exists($data_file)}} is False
        Create File   ${data_file}
    END
    IF  ${{os.path.exists($var_dir_path)}} is False
        Create Directory   ${var_dir_path}
    END
    IF  ${{os.path.exists($var_file)}} is False
        Create File   ${var_file}
    END

    
    # ${PO_Number}=  FakerLibrary.Numerify  %#####
    # ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    # Log  ${EXECDIR}/TDD/${ENVIRONMENT}_varfiles/providers.py
    ${num}=  find_last  ${var_file}
    ${PH_Number}    Random Number 	digits=5  #fix_len=True
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PUSERPH0}  555${PH_Number}
    FOR  ${index}  IN RANGE   ${count}
        ${num}=  Evaluate   ${num}+1
        ${ph}=  Evaluate   ${PUSERPH0}+${index}
        Log   ${ph}
        # ${ph1}=  Evaluate  ${ph}+1000000000
        # ${ph2}=  Evaluate  ${ph}+2000000000
        # ${licresp}=   Get Licensable Packages
        # Should Be Equal As Strings  ${licresp.status_code}  200
        # # Log   ${licresp.content}
        # ${liclen}=  Get Length  ${licresp.json()}
        # Set Test Variable  ${licpkgid}  ${licresp.json()[0]['pkgId']}
        # Set Test Variable  ${licpkgname}  ${licresp.json()[0]['displayName']}
        ${licpkgid}  ${licpkgname}=  get_highest_license_pkg
        ${corp_resp}=   get_iscorp_subdomains  1
        
        ${resp}=  Get BusinessDomainsConf
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        
        ${dom_len}=  Get Length  ${resp.json()}
        ${dom}=  random.randint  ${0}  ${dom_len-1}
        ${sdom_len}=  Get Length  ${resp.json()[${dom}]['subDomains']}
        Set Test Variable  ${domain}  ${resp.json()[${dom}]['domain']}
        Log   ${domain}
        FOR  ${subindex}  IN RANGE  ${sdom_len}
            ${sdom}=  random.randint  ${0}  ${sdom_len-1}
            Set Test Variable  ${subdomain}  ${resp.json()[${dom}]['subDomains'][${subindex}]['subDomain']}
            ${is_corp}=  check_is_corp  ${subdomain}
            Exit For Loop If  '${is_corp}' == 'False'
        END
        Log   ${subdomain}
        
        ${fname}=  FakerLibrary.name
        ${lname}=  FakerLibrary.lastname
        ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${domain}  ${subdomain}  ${ph}  ${licpkgid}
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Activation  ${ph}  0
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
        # Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        sleep  03s
        ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200
        Append To File  ${data_file}  ${ph} - ${PASSWORD}${\n}
        Append To File  ${var_file}  PUSERNAME${num}=${ph}${\n}
        
        ${list}=  Create List  1  2  3  4  5  6  7
        # ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
        # ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
        ${views}=  Evaluate  random.choice($Views)  random
        ${name1}=  FakerLibrary.name
        ${name2}=  FakerLibrary.name
        ${name3}=  FakerLibrary.name
        # ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
        # ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
        ${emails1}=  Emails  ${name3}  Email  ${ph}${P_Email}.${test_mail}  ${views}
        ${bs}=  FakerLibrary.bs
        ${companySuffix}=  FakerLibrary.companySuffix
        ${parking}   Random Element   ${parkingType}
        ${24hours}    Random Element    ['True','False']
        ${desc}=   FakerLibrary.sentence
        ${url}=   FakerLibrary.url
        ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
        ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
        Set Suite Variable  ${tz}
        ${DAY1}=  db.get_date_by_timezone  ${tz}
        ${Time}=  db.get_time_by_timezone  ${tz}
        ${sTime}=  db.add_timezone_time  ${tz}  0  15  
        ${eTime}=  db.add_timezone_time  ${tz}  0  45  
        ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${EMPTY}  ${EMPTY}  ${emails1}   ${EMPTY}
        # Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${resp}=  Get Business Profile
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${account_id}  ${resp.json()['id']}

        ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
        Log  ${fields.content}
        Should Be Equal As Strings    ${fields.status_code}   200

        ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

        ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${spec}=  get_Specializations  ${resp.json()}
        
        ${resp}=  Update Specialization  ${spec}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

        ${resp}=  Get Features  ${subdomain}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${service_name}  ${resp.json()['features']['defaultServices'][0]['service']}
        Set Test Variable  ${service_duration}  ${resp.json()['features']['defaultServices'][0]['duration']}
        Set Test Variable  ${service_status}  ${resp.json()['features']['defaultServices'][0]['status']}    

        ${resp}=  Get Service
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Verify Response List   ${resp}  0  name=${service_name}  status=${service_status}  serviceDuration=${service_duration}

        ${resp}=  Get Order Settings by account id
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        # Should Be Equal As Strings  ${resp.json()['account']}         ${account_id}
        # Should Be Equal As Strings  ${resp.json()['enableOrder']}     ${bool[0]}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['firstName']}    ${fname}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['lastName']}     ${lname}
        # Should Be Equal As Strings  ${resp.json()['storeContactInfo']['phone']}        ${ph}

        # ${resp}=  Provider Change Password  ${PASSWORD}  ${NEW_PASSWORD}
        # Should Be Equal As Strings    ${resp.status_code}    200
        # ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${NEW_PASSWORD}
        # Should Be Equal As Strings    ${resp.status_code}    200
    
    END