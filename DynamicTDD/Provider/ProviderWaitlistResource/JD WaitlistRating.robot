*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitist
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
@{rating}                Exellent   Very Good    Good    Fair    Poor
@{rating_stars}          5    4    3     2     1

*** Test Cases ***
JD-TC-Waitist Rating-1
    [Documentation]   a provider Waitlisted consumer gives Rating 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Rating     ${PUSERNAME58}
    clear_queue      ${PUSERNAME58}
    clear_location   ${PUSERNAME58}
    clear_service    ${PUSERNAME58}
    clear_customer    ${PUSERNAME58}

    ${highest_package}=  get_highest_license_pkg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Change License Package  ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.name
    Set Test Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Test Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}      
    ${q_name}=    FakerLibrary.name
    Set Test Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable    ${desc}
    ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[0]}   ${rating[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[0]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[0]}
    
JD-TC-Waitist Rating-2
    [Documentation]   a provider Waitlisted same consumer gives two Ratings

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_U}=  Evaluate  ${PUSERNAME}+8899641
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_U}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_U}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_U}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_U}${\n}
    Set Suite Variable  ${PUSERNAME_U}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_U}+15566124
    ${ph2}=  Evaluate  ${PUSERNAME_U}+25566128
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_U}.${test_mail}  ${views}
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
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
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

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Test Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Test Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Test Variable    ${ser_id2}    ${resp}      
    ${q_name}=    FakerLibrary.name
    Set Test Variable    ${q_name}   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}    ${parallel}    ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[0]}   ${rating[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[0]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[0]}
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[1]}   ${rating[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[1]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[1]}
    ${avg_rating1}=   Evaluate    ${rating_stars[0]}.0+${rating_stars[1]}.0
    ${avg_rating}=    Evaluate    ${avg_rating1}/2.0
    Set Suite Variable    ${avg_rating}

JD-TC-Waitist Rating-3
    [Documentation]   a provider Waitlisted different consumer gives three Ratings

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Rating     ${PUSERNAME11}
    clear_queue      ${PUSERNAME11}
    clear_location   ${PUSERNAME11}
    clear_service    ${PUSERNAME11}
    
    ${resp}=  AddCustomer  ${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}      
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}    ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid3}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[0]}   ${rating[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[0]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[0]}
    
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[1]}   ${rating[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[1]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[1]}
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid3}  
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[3]}   ${rating[3]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${uuid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['rating']['stars']}                     ${rating_stars[3]}
    Should Be Equal As Strings  ${resp.json()['rating']['feedback'][0]['comments']}   ${rating[3]}
    ${avg_rating2}=   Evaluate    ${rating_stars[0]}.0+${rating_stars[1]}.0+${rating_stars[3]}
    ${avg_rating3}=    Evaluate   ${avg_rating2}/3.0 
    ${avg_round}=     roundval    ${avg_rating3}   2
    Set Suite Variable    ${avg_round}    
  
JD-TC-Waitlist Rating -UH1
    [Documentation]  without login and try for rating

    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[4]}   ${rating[4]}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Waitlist Rating -UH2
    [Documentation]  comsumer try for rating providers url

    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Waitlist Rating  ${uuid}   ${rating_stars[4]}   ${rating[4]}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"   
    
JD-TC-Verify Waitist Rating-1
    [Documentation]   Verify Business profile after Consumer Rating     
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}     ${rating_stars[0]}.0

JD-TC-Verify Waitist Rating-2
    [Documentation]   Verify Business profile after Consumer Rating           
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}     ${avg_rating}

JD-TC-Verify Waitist Rating-3
    [Documentation]   Verify Business profile after Consumer Rating   

    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['avgRating']}     ${avg_round}
