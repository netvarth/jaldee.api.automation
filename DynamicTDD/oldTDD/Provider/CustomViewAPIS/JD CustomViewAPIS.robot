*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        CustomView
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***
${SERVICE1}   SERVICE1
${type}  Waitlist
${type1}  Appointment

***Test Cases***

JD-TC-CustomViewAPIS-1
    [Documentation]  Creating a CustomView using DepartmentId, ServicesId, QueuesId and UsersId
    clear_service      ${PUSERNAME0}
    clear_location    ${PUSERNAME0}
    clear_queue         ${PUSERNAME0}
    
    # Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    # ${domresp}=  Get BusinessDomainsConf
    # Log   ${domresp.content}
    # Should Be Equal As Strings  ${domresp.status_code}  200
    # ${dlen}=  Get Length  ${domresp.json()}
# *** Comments ***
    # FOR  ${pos}  IN RANGE  ${dlen}  
    #     Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
    #     ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
    #     Set Suite Variable   ${sd1}
    #     Exit For Loop IF     '${check}' == '${bool[1]}'
    # END
    # Log  ${d1}
    # Log  ${sd1}
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}

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

# *** Comments ***

    ${pid}=  get_acc_id  ${PUSERNAME0}
    Set Suite Variable  ${pid}
   
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
  
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${city}=   get_place
    Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    Set Suite Variable  ${postcode}
    # ${address}=  get_address
    Set Suite Variable  ${address}
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}

    ${resp}=  Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp1}=  Run Keyword If  ${resp.json()['filterByDept']}==${bool[0]}   Toggle Department Enable
    Run Keyword If  '${resp1}' != '${None}'   Log  ${resp1.content}
    Run Keyword If  '${resp1}' != '${None}'   Should Be Equal As Strings  ${resp1.status_code}  200
    # ${resp}=  Toggle Department Enable
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_desc}=  FakerLibrary.sentence
    Set Suite Variable   ${dep_desc}
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable    ${dep_name2}
    ${dep_code2}=   Random Int  min=1000   max=9999  
    Set Suite Variable    ${dep_code2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid02}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    Set Suite Variable    ${desc}
    ${total_amount}=    Random Int   min=100  max=500
    ${min_prepayment}=  Random Int   min=1    max=50
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid05}  ${resp.json()}


    ${resp}=  Get Department ById  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid02}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid05}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=  add_timezone_time  ${tz}  1  00  
    ${end_time}=   add_timezone_time  ${tz}  3  00     
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${sid05}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${BUSER0}=  Evaluate  ${PUSERNAME0}+321651
    clear_users  ${BUSER0}
    Set Suite Variable  ${BUSER0}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    # ${pin}=  get_pincode
    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${BUSER0}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${BUSER0}  ${dep_id02}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${BUSER0}  ${countryCodes[0]}  ${BUSER0}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${state1} = 	Convert To Lower Case 	${state}
    ${state2} = 	Convert To Lower Case 	${resp.json()['state']}
    Should Be Equal As Strings   ${state1}  ${state2}
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${BUSER0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${BUSER0}.${test_mail}  
    ...  deptId=${depid02}  subdomain=${userSubDomain}  
    # ...  address=${address}  city=${district}  locationName=${city}  state=${state}  
    
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=30
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${loc_id1}  ${duration}  ${bool1}  ${sid05} 
    Log  ${resp.content}
    Set Suite Variable   ${sc_id}   ${resp.json()} 
    ${Schid}=  Create List  ${sc_id}
    Set Suite Variable  ${Schid} 
    ${dep_id}=  Create List   ${depid02}
    Set Suite Variable   ${dep_id}
    ${s_id}=  Create List  ${sid05}    
    Set Suite Variable  ${s_id} 
    ${que_id}=  Create List  ${que_id1}  
    Set Suite Variable   ${que_id} 
    ${u_id1}=  Create List  ${u_id} 
    Set Suite Variable   ${u_id1} 
    ${name}=   FakerLibrary.word
    ${resp}=   Create CustomeView   ${name}  ${bool[1]}  ${dep_id}  ${s_id}  ${que_id}  ${u_id1}  ${type}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  


JD-TC-CreateCustomViewApis-H2
    [Documentation]  Trying to Create CustomView With Appointment
    ${resp}=  Encrypted Provider Login   ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name2}=  FakerLibrary.name
    Log  ${dep_id}
    ${resp}=   Create CustomeView Appointment   ${name2}  ${bool[1]}  ${dep_id}  ${s_id}   ${u_id1}   ${Schid}   ${type1}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200  


***Comments***
JD-TC-CustomViewAPIS-2
    [Documentation]  Creating a CustomView using DepartmentId, ServicesId, QueuesId and UsersId
    clear_service      ${PUSERNAME0}
    clear_location    ${PUSERNAME0}
    clear_queue         ${PUSERNAME0}
    # ${iscorp_subdomains}=  get_iscorp_subdomains  1
    # Log  ${iscorp_subdomains}
    # Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    # Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    # Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${resp}=  Encrypted Provider Login   ${PUSERNAME0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${subdomain}  ${resp.json()['subSector']}

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
    

    ${pid}=  get_acc_id  ${PUSERNAME0}
    Set Suite Variable  ${pid}
   
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
  
    # ${city}=   get_place
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
    ${24hours}    Random Element    ['True','False']
    Set Suite Variable  ${24hours}
    ${sTime}=  add_timezone_time  ${tz}  5  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  6  30  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parkingType[0]}  ${24hours}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable    ${loc_id1}    ${resp.json()}

    #${resp}=  Toggle Department Enable
    #Should Be Equal As Strings  ${resp.status_code}  200
   #${resp}=  Toggle Department Enable
    #Should Be Equal As Strings  ${resp.status_code}  200

    ${dep_desc}=  FakerLibrary.sentence
    Set Suite Variable   ${dep_desc}
    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable    ${dep_name2}
    ${dep_code2}=   Random Int  min=1000   max=9999  
    Set Suite Variable    ${dep_code2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid02}  ${resp.json()}

    ${desc}=   FakerLibrary.sentence
    Set Suite Variable    ${desc}
    ${total_amount}=    Random Int   min=100  max=500
    ${min_prepayment}=  Random Int   min=1    max=50
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid05}  ${resp.json()}

    ${resp}=  Get Department ById  ${depid02}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid02}  departmentCode=${dep_code2}  departmentDescription=${dep_desc}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid05}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${strt_time}=  add_timezone_time  ${tz}  1  00  
    ${end_time}=   add_timezone_time  ${tz}  3  00     
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${sid05}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${PUSERNAME0}=  Evaluate  ${PUSERNAME0}+321650
    clear_users  ${PUSERNAME0}
    Set Suite Variable  ${PUSERNAME0}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${address}=  get_address
    Set Suite Variable  ${address}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable  ${state}

    ${resp}=  Create User  ${firstname}  ${lastname}  ${address}  ${PUSERNAME0}  ${dob}    ${Genderlist[0]}  ${userType[0]}  ${P_Email}${PUSERNAME0}.${test_mail}  ${location}  ${state}  ${depid02}  ${sub_domain_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  address=${address}  mobileNo=${PUSERNAME0}  dob=${dob}  gender=${Genderlist[0]}  userType=${userType[0]}  status=ACTIVE  email=${P_Email}${PUSERNAME0}.${test_mail}  city=${location}  state=${state}  deptId=${depid02}  subdomain=${userSubDomain}

    ${name}=   FakerLibrary.word
    ${resp}=   Create CustomeView   ${name}  ${bool[1]}  ${depid02}  ${sid05}  ${que_id1}  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

