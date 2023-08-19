*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Provider Signup
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
# Library           /ebs/TDD/ynw.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot


*** Variable **

# ${BASE_URL}       http://localhost:8080/v1/rest
${P_Email}        s_p
${PRONUM}   5550000000

*** Test Cases ***

JD-TC-Provider_Signup

    [Documentation]    Create a provider with all valid attributes
    
    ${sTime}=  add_time  0  15
    ${eTime}=  add_time   0  45

    ${randint}    Generate Random String    length=4    chars=[NUMBERS]
    ${index}  Convert To Integer    ${randint}
    Log   ${index}
    ${ph}=  Evaluate  ${PRONUM}+${index}
    Log   ${ph}

    ${licresp}=   Get Licensable Packages
    # Log to Console   ${licresp.content}
    Log  ${licresp.content}
    Should Be Equal As Strings  ${licresp.status_code}  200
    ${liclen}=  Get Length  ${licresp.json()}
    # Log to Console   ${liclen}
    Log  ${liclen}
    ${lic_index}=  random.randint  ${0}  ${liclen-1}
    Set Test Variable  ${licid}  ${licresp.json()[${lic_index}]['pkgId']}
    # Log to Console   ${licid}
    Log  ${licid}
    Set Test Variable  ${licname}  ${licresp.json()[${lic_index}]['displayName']}
    # Log to Console   ${licname}
    Log  ${licname}
    
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    ${dom_index}=  random.randint  ${0}  ${len-1}
    Set Test Variable  ${dom}  ${resp.json()[${dom_index}]['domain']}
    # Log to Console   ${dom}
    Log   ${dom}
    ${sublen}=  Get Length  ${resp.json()[${dom_index}]['subDomains']}
    FOR  ${subindex}  IN RANGE  ${sublen}
        ${sdom_index}=  random.randint  ${0}  ${sublen-1}
        Set Test Variable  ${sdom}  ${resp.json()[${dom_index}]['subDomains'][${sdom_index}]['subDomain']}
        ${is_corp}=  check_is_corp  ${sdom}
        Log  ${is_corp}
        Exit For Loop If  '${is_corp}' == 'False'
    END
    # Log to Console   ${sdom}
    Log   ${sdom}
    
    ${fname}=  FakerLibrary.name
    ${lname}=  FakerLibrary.lastname
    ${resp}=  Account SignUp  ${fname}  ${lname}  ${None}  ${dom}  ${sdom}  ${ph}  ${licid}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${ph}  0
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${ph}  ${PASSWORD}  0
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep  03s

    ${resp}=  Provider Login  ${ph}  ${PASSWORD}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/phnumbers.txt  ${ph}${\n}

    
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${ph}+10000
    ${ph2}=  Evaluate  ${ph}+20000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${ph}.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}  ${longi}=  get_lat_long
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${url}=   FakerLibrary.url

    ${resp}=  Update Business Profile with schedule  ${bs}  ${bs} Desc   ${companySuffix}  ${city}  ${longi}  ${latti}  ${url}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${acc_id}=  Set Variable  ${resp.json()['id']}

    ${ph}=  Convert To String  ${ph}
    # ${pid}=  get_acc_id  ${ph}
    # Log to Console   ${pid}
    Log   ${acc_id}

    Append To File  ${EXECDIR}/phnumbers.txt  ${ph},${acc_id},${licname}${\n}
    # Append To File  ${EXECDIR}/${licname}login.txt  ${ph},${pid}${\n}
    sleep  05s

    ${fields}=   Get subDomain level Fields  ${dom}  ${sdom}
    # Log to Console   ${fields.content}
    Log   ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sdom}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${dom}  ${sdom}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    # Log to Console   ${resp.content}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200



