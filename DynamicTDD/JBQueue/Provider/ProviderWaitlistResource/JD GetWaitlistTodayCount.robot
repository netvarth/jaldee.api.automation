*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***
${waitlistedby}           PROVIDER
@{service_names}

*** Test Cases ***

JD-TC-GetWaitlistCountToday-1   
      [Documentation]   View Waitlist by Provider login

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${decrypted_data}=  db.decrypt_data  ${resp.content}
      Log  ${decrypted_data}
      Set Suite Variable  ${lic_id}  ${decrypted_data['accountLicenseDetails']['accountLicense']['licPkgOrAddonId']}
      Set Suite Variable  ${lic_name}  ${decrypted_data['accountLicenseDetails']['accountLicense']['name']}


      ${resp}=   Get License UsageInfo 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${pkg_id}=   get_highest_license_pkg
      Log   ${pkg_id}
      Set Suite Variable  ${pkgId}   ${pkg_id[0]}

      IF  '${lic_id}' != '${pkgId}'
          ${resp}=  Change License Package  ${pkgId}
          Should Be Equal As Strings    ${resp.status_code}   200
      END

      ${duration}=  Random Int  min=2   max=10
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=    Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      IF   '${resp.content}' == '${emptylist}'
            ${loc_id1}=  Create Sample Location
            ${resp}=   Get Location ById  ${loc_id1}
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ELSE
            Set Suite Variable  ${loc_id1}  ${resp.json()[0]['id']}
            Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
      END 

      ${ser_name1}=     generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${ser_name1}
      Set Suite Variable    ${ser_name1} 

      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id1}    ${resp}  

      ${ser_name2}=     generate_unique_service_name  ${service_names}
      Append To List  ${service_names}  ${ser_name2}
      Set Suite Variable    ${ser_name2} 
      ${resp}=   Create Sample Service  ${ser_name2}
      Set Suite Variable    ${ser_id2}    ${resp}  

      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1} 
      ${strt_time}=   db.subtract_timezone_time   ${tz}   3  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  0  20 
      Set Suite Variable    ${end_time} 
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}  
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}

      ${cname1}=    FakerLibrary.name
      Set Suite Variable    ${cname1}
      ${lname1}=    FakerLibrary.name
      Set Suite Variable    ${lname1}

      ${resp}=  AddCustomer  ${CUSERNAME0}  firstName=${cname1}   lastName=${lname1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      Set Suite Variable    ${desc}
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id}  ${tid[0]}

      ${cname2}=    FakerLibrary.name
      Set Suite Variable    ${cname2}
      ${lname2}=    FakerLibrary.name
      Set Suite Variable    ${lname2}

      ${resp}=  AddCustomer  ${CUSERNAME1}   firstName=${cname2}   lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id1}  ${tid[0]}

      ${cname3}=    FakerLibrary.name
      Set Suite Variable    ${cname3}
      ${lname3}=    FakerLibrary.name
      Set Suite Variable    ${lname3}

      ${resp}=  AddCustomer  ${CUSERNAME2}   firstName=${cname3}   lastName=${lname3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id2}  ${tid[0]}

       ${cname4}=    FakerLibrary.name
      Set Suite Variable    ${cname4}
      ${lname4}=    FakerLibrary.name
      Set Suite Variable    ${lname4}

      ${resp}=  AddCustomer  ${CUSERNAME3}   firstName=${cname4}   lastName=${lname4} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid3}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid3}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id3}  ${tid[0]}
      ${resp}=  Get Waitlist Today  
      Log   ${resp.json()}
      Set Suite Variable    ${cname0}    ${resp.json()[0]['consumer']['firstName']}
      Set Suite Variable    ${cname1}    ${resp.json()[1]['consumer']['firstName']}
      Set Suite Variable    ${cname2}    ${resp.json()[2]['consumer']['firstName']}
      Set Suite Variable    ${cname3}    ${resp.json()[3]['consumer']['firstName']}
      Should Be Equal As Strings  ${resp.status_code}  200

      sleep  1s
      ${resp}=  Get Waitlist Count Today
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistCountToday-2
      [Documentation]   View Waitlist after cancel

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action      ${waitlist_actions[2]}    ${waitlist_id}  cancelReason=${waitlist_cancl_reasn[4]}         
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
      ${resp}=  Get Waitlist Count Today  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0
      
JD-TC-GetWaitlistCountToday-3
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-4
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-5
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-6
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-neq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistCountToday-7
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-8
      [Documentation]   Get waitlist firstName-eq=${cname0} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-10
      [Documentation]   Get waitlist firstName-neq=${cname0} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-11
      [Documentation]   Get waitlist firstName-eq=${cname1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-12
      [Documentation]   Get waitlist firstName-neq=${cname1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3


JD-TC-GetWaitlistCountToday-13
      [Documentation]   Get waitlist service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistCountToday-14
      [Documentation]   Get waitlist waitlistStatus-eq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  DONE  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count Today  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-15
      [Documentation]   Get waitlist waitlistStatus-neq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count Today  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-16
      [Documentation]   Get waitlist service-neq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 

      
      # ${resp}=  AddCustomer  ${CUSERNAME0}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id4}  ${tid[0]}

      # ${resp}=  AddCustomer  ${CUSERNAME1}
      # Log   ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      # Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-17
      [Documentation]   Get waitlist firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-18
      [Documentation]   Get waitlist firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-19
      [Documentation]   Get waitlist firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-20
      [Documentation]   Get waitlist firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistCountToday-21
      [Documentation]   Get waitlist firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-22
      [Documentation]   Get waitlist firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-23
      [Documentation]   Get waitlist firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0


JD-TC-GetWaitlistCountToday-24
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-25
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[5]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  4

JD-TC-GetWaitlistCountToday-26
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-27
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-28
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-29
      [Documentation]   Get waitlist firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-30
      [Documentation]   Get waitlist firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-31
      [Documentation]   Get waitlist firstName-eq=${cname0}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-32
      [Documentation]   Get waitlist firstName-neq=${cname0}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-33
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-34
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  service-neq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
   
JD-TC-GetWaitlistCountToday-35
      [Documentation]   Get waitlist firstName-eq=${cname0}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname0}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-36
      [Documentation]   Get waitlist firstName-neq=${cname0}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname0}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-37
      [Documentation]   Get waitlist firstName-eq=${cname1}  service-eq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-eq=${cname1}  service-eq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-38
      [Documentation]   Get waitlist firstName-neq=${cname1}  service-neq=${ser_id2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  firstName-neq=${cname1}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-39
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-40
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-41
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-42
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-43
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-44
      [Documentation]   Get waitlist service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id1}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-45
      [Documentation]   Get waitlist service-eq=${ser_id1}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id1}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-46
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[0]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[0]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-47
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-48
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-49
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-50
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[5]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-51
      [Documentation]   Get waitlist service-eq=${ser_id2}   waitlistStatus-eq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  service-eq=${ser_id2}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-52
      [Documentation]   Get waitlist service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200      
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2

JD-TC-GetWaitlistCountToday-53
      [Documentation]   Get waitlist token-eq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  token-eq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-54
      [Documentation]   Get waitlist token-neq=${token_id}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  token-neq=${token_id}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  5

JD-TC-GetWaitlistCountToday-55
      [Documentation]   Get waitlist token-eq=${token_id}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  token-eq=${token_id}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0

JD-TC-GetWaitlistCountToday-56
      [Documentation]   Get waitlist token-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  token-eq=${token_id}  service-eq=${ser_id1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-57
      [Documentation]   Get waitlist token-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=  Get Waitlist Count Today  token-neq=${token_id}  service-neq=${ser_id2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

JD-TC-GetWaitlistCountToday-58
      [Documentation]   Get waitlist count today location-eq=${lid1} from=0  count=10
      clear_customer   ${HLPUSERNAME22}

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME3}    
      # ...    firstName=${cname2}  
      # ...      lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer ById  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}

      ${resp}=   Create Sample Location
      Set Suite Variable    ${lid1}    ${resp}  
      ${ser_name4}=   FakerLibrary.word
      Set Suite Variable    ${ser_name4} 
      ${resp}=   Create Sample Service  ${ser_name4}
      Set Suite Variable    ${ser_id4}    ${resp}  
      ${ser_name5}=   FakerLibrary.word
      Set Suite Variable    ${ser_name5} 
      ${resp}=   Create Sample Service  ${ser_name5}
      Set Suite Variable    ${ser_id5}    ${resp}  
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}  
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${lid1}  ${ser_id4}  ${ser_id5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid2}   ${resp.json()} 
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}  location=${lid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id6}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id7}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id7}  ${tid[0]}
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
      
JD-TC-GetWaitlistCountToday-59
      [Documentation]   Get waitlist count todaylocation-eq=${lid1} service-eq=${ser_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}   service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2     
      
JD-TC-GetWaitlistCountToday-60
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
    
JD-TC-GetWaitlistCountToday-61
      [Documentation]   Get waitlist count today location-eq=${lid1}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id6}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  2
      
JD-TC-GetWaitlistCountToday-62
      [Documentation]   Get waitlist count today location-eq=${lid1}  waitlistStatus-eq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-63
      [Documentation]   Get waitlist count today location-eq=${lid1}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Waitlist Action      ${waitlist_actions[2]}    ${waitlist_id5}   cancelReason=${waitlist_cancl_reasn[3]}       
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   2s
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-64
      [Documentation]   Get waitlist count today location-eq=${lid1}  token-eq=${token_id5}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  token-eq=${token_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-65
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2} service-eq=${ser_id4} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  service-eq=${ser_id4}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1             

JD-TC-GetWaitlistCountToday-66
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1     

JD-TC-GetWaitlistCountToday-67
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1     


JD-TC-GetWaitlistCountToday-68
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id7}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id7}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1     

JD-TC-GetWaitlistCountToday-69
      [Documentation]   Get waitlist count today location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  waitlistStatus-eq=${wl_status[1]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  queue-eq=${qid2}  token-eq=${token_id5}  waitlistStatus-eq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  0     

JD-TC-GetWaitlistCountToday-70
      [Documentation]   Get waitlist queue-eq=${qid2} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200       
      ${resp}=  Get Waitlist Count Today     queue-eq=${qid2}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3     

JD-TC-GetWaitlistCountToday-71
      [Documentation]   Get queue-eq=${qid2} service-eq=${ser_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200   
      ${resp}=  Get Waitlist Count Today   queue-eq=${qid2}   service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200 
      Should Be Equal As Integers  ${resp.json()}    2     

JD-TC-GetWaitlistCountToday-72
      [Documentation]   Get waitlist queue-eq=${qid2}  waitlistStatus-eq=${wl_status[2]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today   queue-eq=${qid2}  waitlistStatus-eq=${wl_status[2]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-73
      [Documentation]   Get waitlist queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today   queue-eq=${qid2}  waitlistStatus-eq=${wl_status[4]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1
 
JD-TC-GetWaitlistCountToday-74
      [Documentation]   Get waitlist queue-eq=${qid2}  location-eq=${lid1}  from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today   queue-eq=${qid2}  location-eq=${lid1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3
  
JD-TC-GetWaitlistCountToday-75
      [Documentation]   Get waitlist  waitlistStatus-eq=${wl_status[1]}  queue-eq=${qid2} service-eq=${ser_id5} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200  
      ${resp}=  Get Waitlist Count Today   waitlistStatus-eq=${wl_status[1]}  queue-eq=${qid2}  service-eq=${ser_id5}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1     

JD-TC-GetWaitlistCountToday-76
      [Documentation]   Get Today Waitlist count of a family member. 
      # clear_queue      ${PUSERNAME49}
      # clear_location   ${PUSERNAME49}
      # clear_service    ${PUSERNAME49}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${ser_duratn}=  Random Int   min=2   max=4
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id11}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id11}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ${ser_name11}=   FakerLibrary.word
      Set Suite Variable    ${ser_name11} 
      ${resp}=   Create Sample Service  ${ser_name11}
      Set Suite Variable    ${ser_id11}    ${resp}   
      
      ${q_name1}=    FakerLibrary.name
      ${strt_time}=   db.subtract_timezone_time   ${tz}  2  00
      ${end_time}=    db.add_timezone_time  ${tz}       0  20 
      ${parallel}=   Random Int  min=1   max=2
      ${capacity}=  Random Int   min=10   max=20
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id11}  ${ser_id11}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id11}   ${resp.json()} 

      ${resp}=  AddCustomer  ${CUSERNAME30}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${f_name}=   generate_firstname
      Set Suite Variable  ${f_name}
      ${l_name}=   FakerLibrary.last_name
      Set Suite Variable  ${l_name}
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${f_name}  ${l_name}  ${dob}  ${gender} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid}  ${ser_id11}  ${que_id11}  ${DAY1}  ${desc}  ${bool[1]}  ${mem_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id11}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id11}  ${tid[0]}
      ${resp}=  Get provider communications
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Today  
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${len}=  Get Length  ${resp.json()}
      Should Be Equal As Integers  ${len}  1
      Verify Response List  ${resp}  0  ynwUuid=${waitlist_id11}

      ${resp}=  Get Waitlist Count Today
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-77
      [Documentation]  Get Today Waitlist count By first name of family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist Count Today  waitlistingFor-eq=firstName::${f_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-78
      [Documentation]  Get Today Waitlist count By last name of family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME49}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist Count Today  waitlistingFor-eq=lastName::${l_name}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  1

JD-TC-GetWaitlistCountToday-UH1
      [Documentation]   Get waitlist using consumer login

      ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${account_id}  ${resp.json()['id']} 

      #............provider consumer creation..........

      ${PH_Number}=  FakerLibrary.Numerify  %#####
      ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
      Log  ${PH_Number}
      Set Suite Variable  ${PCPHONENO}  555${PH_Number}

      ${fname}=  generate_firstname
      Set Suite Variable  ${fname}
      ${lastname}=  FakerLibrary.last_name

      ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]} 
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Provider Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}
      ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}   JSESSIONYNW=${jsessionynw_value}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}

      ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200   
      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-GetWaitlistCountToday-UH2
      [Documentation]   Get waitlist without login

      ${resp}=  Get Waitlist Count Today  service-neq=${ser_id2}  waitlistStatus-neq=${wl_status[1]}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"

*** Comments ***
      
JD-TC-GetWaitlistCountToday-58
      [Documentation]   Get waitlist count today location-eq=${lid1} from=0  count=10

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME3}    
      # ...    firstName=${cname2}  
      # ...      lastName=${lname2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${resp}=  GetCustomer ById  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}

      ${resp}=   Create Sample Location
      Set Suite Variable    ${lid1}    ${resp}  
      ${ser_name4}=   FakerLibrary.word
      Set Suite Variable    ${ser_name4} 
      ${resp}=   Create Sample Service  ${ser_name4}
      Set Suite Variable    ${ser_id4}    ${resp}  
      ${ser_name5}=   FakerLibrary.word
      Set Suite Variable    ${ser_name5} 
      ${resp}=   Create Sample Service  ${ser_name5}
      Set Suite Variable    ${ser_id5}    ${resp}  
      ${q_name1}=    FakerLibrary.name
      Set Suite Variable    ${q_name1}  
      ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${lid1}  ${ser_id4}  ${ser_id5} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid2}   ${resp.json()} 
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id5}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id5}  ${tid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id6}  ${wid[0]}

      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id5}  ${qid2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id7}  ${wid[0]}
      ${tid}=  Get Dictionary Keys  ${resp.json()}
      Set Suite Variable  ${token_id7}  ${tid[0]}
      ${resp}=  Get Waitlist Count Today  location-eq=${lid1}  from=0  count=10
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Integers  ${resp.json()}  3

