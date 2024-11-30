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

***Variables***

${count}   5 
 

*** Test Cases ***

JD-TC-change Waitlist Action for multiple account-1
      [Documentation]   Waitlist Action multiple account Done after STARTED

      # clear_queue      ${HLPUSERNAME27}
      # clear_location   ${HLPUSERNAME27}
      # clear_service    ${HLPUSERNAME27}
      clear_customer    ${HLPUSERNAME27}

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp} 
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']} 
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
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}
      ${strt_time}=   db.subtract_timezone_time   ${tz}  3  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  0  30 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}
    

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
     # Set Suite Variable  ${waitlist_id1}  ${wid[1]}
      

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id2}  ${resp.json()}
    
      ${desc2}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc2}  ${bool[1]}  ${cons_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid2[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}   ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

JD-TC-change Waitlist Action for multiple account-2
      [Documentation]   Waitlist Action multiple account Done in  different services
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${resp}=  AddCustomer  ${CUSERNAME5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id2}  ${resp.json()}
    
      ${desc2}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id2}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc2}  ${bool[1]}  ${cons_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid2[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}   ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

   

JD-TC-change Waitlist Action for multiple account-3
      [Documentation]   Waitlist Action multiple account Done after Check_in
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${resp}=  AddCustomer  ${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME6}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id2}  ${resp.json()}
    
      ${desc2}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id2}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc2}  ${bool[1]}  ${cons_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid2[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}   ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
   
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

JD-TC-change Waitlist Action for multiple account-4
      [Documentation]   Waitlist Action cunsumer and family member Done after Check_in
      
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${lname}=   FakerLibrary.last_name
      ${fname}=   generate_firstname
      ${resp}=  AddCustomer  ${CUSERNAME9}  firstName=${fname}   lastName=${lname}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}   ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${mem_fname}=   generate_firstname
      ${mem_lname}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${cid}  ${mem_fname}  ${mem_lname}  ${dob}  ${Genderlist[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}

      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['id']}   ${mem_id}
      
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}   ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${desc1}=   FakerLibrary.word
      ${resp}=  Add To Waitlist   ${mem_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}   ${mem_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid1}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid1[1]}

      ${resp}=  Waitlist Action   ${waitlist_actions[3]}    ${waitlist_id}
      Should Be Equal As Strings   ${resp.status_code}  200
      
      ${resp}=  Waitlist Action   ${waitlist_actions[3]}    ${waitlist_id2}
      Should Be Equal As Strings   ${resp.status_code}    200

      ${resp}=  Get Waitlist By Id   ${waitlist_id}
      Should Be Equal As Strings   ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}
      
      ${resp}=  Waitlist Action multiple account   ${waitlist_actions[4]}    ${waitlist_id}   ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}   200
   
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings   ${resp.status_code}   200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}

      ${resp}=  Get Waitlist By Id    ${waitlist_id2}
      Should Be Equal As Strings    ${resp.status_code}   200
      Verify Response  ${resp}       waitlistStatus=${wl_status[5]}

JD-TC-change Waitlist Action for multiple account -5
      [Documentation]    Waitlist DONE  for a checkedIn id

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}    ${waitlist_id2}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}


JD-TC-change Waitlist Action for multiple account UH-1
      [Documentation]   Waitlist Action multiple account empty waitlistid
        

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${resp}=  AddCustomer  ${CUSERNAME13}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME12}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id2}  ${resp.json()}
      
      ${desc2}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id2}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc2}  ${bool[1]}  ${cons_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid2[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${empty}   ${empty}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  "${resp.json()}"   "{'': '${INVALID_WAITLIST}'}"

JD-TC-change Waitlist Action for multiple account UH-2
      [Documentation]  Waitlist Action Done in another provider
      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
       sleep   04s

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}  ${waitlist_id2}
      Log   ${resp.json()}
      Should Contain    "${resp.json()}"   ${INVALID_WAITLIST}  
         
JD-TC-change Waitlist Action for multiple account UH-3
      [Documentation]  waitlist Action without login

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}  ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 

JD-TC-change Waitlist Action for multiple account UH-4
      [Documentation]  waitlist Action using  consumer login

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${account_id}=  get_acc_id  ${HLPUSERNAME25}

      ${PH_Number}=  FakerLibrary.Numerify  %#####
      ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
      Log  ${PH_Number}
      Set Suite Variable  ${PCPHONENO}  555${PH_Number}

      ${fname}=  generate_firstname
      ${lname}=  FakerLibrary.last_name
      Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

      ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}
      ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}
      
      ${resp}=  Provider Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}  ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"



JD-TC-change Waitlist Action for multiple account-6
      [Documentation]   Waitlist Action multiple account 


      # clear_queue      ${HLPUSERNAME27}
      # clear_location   ${HLPUSERNAME27}
      # clear_service    ${HLPUSERNAME27}
      clear_customer    ${HLPUSERNAME27}

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
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
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}
      ${strt_time}=   db.subtract_timezone_time   ${tz}  3  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  0  30 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
    
    
      ${DAY3}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY3}
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${ser_name1}=   FakerLibrary.word
      Set Suite Variable    ${ser_name1} 
      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id3}    ${resp}  
      ${ser_name2}=   FakerLibrary.word
      Set Suite Variable    ${ser_name2} 
      ${resp}=   Create Sample Service  ${ser_name2}
      Set Suite Variable    ${ser_id4}    ${resp}
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   db.subtract_timezone_time   ${tz}  3  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  0  30 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY3}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${loc_id1}  ${ser_id3}  ${ser_id4} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id3}   ${resp.json()}

     
      ${resp}=  AddCustomer  ${CUSERNAME25}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME24}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id2}  ${resp.json()}
    
      ${desc2}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id2}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc2}  ${bool[1]}  ${cons_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid2}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid2[0]}

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}
      
      ${resp}=  AddCustomer  ${CUSERNAME20}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id3}  ${resp.json()}
    
      ${desc3}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id3}  ${ser_id3}  ${que_id3}  ${DAY3}  ${desc3}  ${bool[1]}  ${cons_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid3}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid3[0]}

      ${resp}=  Get Waitlist By Id   ${waitlist_id3}
      Should Be Equal As Strings   ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  AddCustomer  ${CUSERNAME21}
      Log   ${resp.json()}
      Should Be Equal As Strings   ${resp.status_code}  200
      Set Suite Variable  ${cons_id4}   ${resp.json()}
    
      ${desc4}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id4}  ${ser_id4}  ${que_id3}  ${DAY3}  ${desc4}  ${bool[1]}  ${cons_id4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid4}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id4}  ${wid4[0]}

      ${resp}=   Get Waitlist By Id  ${waitlist_id4}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id3}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id3}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id4}   
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id4}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}

      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}   ${waitlist_id2}    ${waitlist_id3}     ${waitlist_id4}
      Log   ${resp.json()}  
      Should Be Equal As Strings  ${resp.status_code}  200
   
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[5]}



JD-TC-change Waitlist Action for multiple account UH-5
      [Documentation]  waitlist Action for another provider's waitlist

      ${resp}=  Encrypted Provider Login   ${HLPUSERNAME25}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id3}  ${waitlist_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Contain    "${resp.json()}"   ${INVALID_WAITLIST}  
     
JD-TC-change Waitlist Action for multiple account UH-6
      [Documentation]   Waitlist DONE for already DONE id

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME27}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action multiple account  ${waitlist_actions[4]}    ${waitlist_id}  ${waitlist_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[5]}   ${wl_status[5]}



