

*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Change Status
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111

${SERVICE4}   checking
${self}   0

${prefix}                   serviceBatch
${suffix}                   serving
${count}       4


${digits}       0123456789
@{dom_list}

*** Test Cases ***  

JD-TC-change appointment status for multiple appointments-1
    [Documentation]   Provider change appointment status for multiple appmt

    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pro_id}  ${decrypted_data['id']}
    # Set Test Variable  ${pro_id}  ${resp.json()['id']}
    
     
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment
    Run Keyword If   '${resp}' != '${None}'  Log  ${resp.json()}
    Run Keyword If   '${resp}' != '${None}'  Should Be Equal As Strings  ${resp.status_code}  200

    clear_service  ${PUSERNAME85}
    clear_location  ${PUSERNAME85}
    clear_customer   ${PUSERNAME85}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}    

   
    
    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
     ${s_id1}=  Create Sample Service  ${SERVICE2}
     Set Suite Variable   ${s_id1}
   
   
      clear_appt_schedule   ${PUSERNAME85}


    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

   ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
  
   

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
     Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}


  
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}


    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor10}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor2}=   Create List  ${apptfor10}
    
    ${cnote2}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote2}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=   Get Dictionary Values  ${resp.json()}  sort_keys=False
    BuiltIn.Set Test Variable  ${apptid2}  ${apptid2[1]}
    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

     ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}


    
    

JD-TC-change appointment status for multiple appointments-2
    [Documentation]   Provider change appointment status in multiple appmt  different service
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
  
   clear_customer   ${PUSERNAME85}
   
    
   clear_appt_schedule   ${PUSERNAME85}

    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}   
     Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}
    
   
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}     batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id1}
    Set Suite Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    
     ${resp}=  Create Sample Schedule  ${lid}   ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id2}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id2}     batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id2}  ${DAY1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id2}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Test Variable   ${apptfor}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}               ${apptid1}
    


    ${resp}=  AddCustomer  ${CUSERNAME8}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}   ${resp.json()}
    
    ${apptfor10}=  Create Dictionary  id=${cid2}   apptTime=${slot2}
    ${apptfor2}=   Create List  ${apptfor10}
    
    ${cnote2}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid2}  ${s_id1}  ${sch_id2}  ${DAY1}  ${cnote2}  ${apptfor2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid2}=   Get Dictionary Values  ${resp.json()}  sort_keys=False
    BuiltIn.Set Test Variable  ${apptid2}  ${apptid2[1]}
    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}    ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

     ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}




JD-TC-change appointment status for multiple appointments UH-1
    [Documentation]   Provider change appointment status in multiple account empty appt ( it was unhappy case .but it responce 200)
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${Empty}    ${Empty}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    


JD-TC-change appointment status for multiple appointments-3
    [Documentation]  appointment status change - consumer and consumer's family member
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
  
    clear_appt_schedule   ${PUSERNAME85}
     

     ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable   ${DAY1}
 
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}     batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    Set Test Variable   ${slot2}   ${resp.json()['availableSlots'][1]['time']}

    ${lname}=   FakerLibrary.last_name
    ${fname}=   FakerLibrary.first_name
    ${resp}=  AddCustomer  ${CUSERNAME10}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}

    
    ${mem_fname}=   FakerLibrary.first_name
    ${mem_lname}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${mem_fname}  ${mem_lname}  ${dob}  ${Genderlist[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${resp}=  ListFamilyMemberByProvider  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${mem_id}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor2}=  Create Dictionary  id=${mem_id}   apptTime=${slot2}
    ${apptfor}=   Create List  ${apptfor1}  ${apptfor2}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${Keys}=  Get Dictionary Keys  ${resp.json()}   sort_keys=False 
    ${apptid1}=  Get From Dictionary  ${resp.json()}  ${mem_fname}
    ${apptid2}=  Get From Dictionary  ${resp.json()}  ${fname}
    
 
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

    
    ${resp}=  Get Appointment By Id   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['apptStatus']}   ${apptStatus[1]}

   
    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}   ${apptid2}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    sleep  2s

    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[1]['appointmentStatus']}     ${apptStatus[6]}

     ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[1]['appointmentStatus']}     ${apptStatus[6]}

    

   
JD-TC-change appointment status for multiple appointments- 4

    [Documentation]    multiple consumer appmt status change arrived to completed  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${s_id}  ${resp.json()[0]['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}  ${resp.json()[0]['id']}
   # Set Test Variable  ${sch_id1}  ${resp.json()['id']}

    clear_appt_schedule   ${PUSERNAME85}
     

     ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Test Variable   ${DAY1}
 
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}     batchEnable=${bool[0]}

  
    ${fname0}=   FakerLibrary.first_name
    ${lname0}=   FakerLibrary.last_name
    FOR   ${b}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${b}}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${b}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${b}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${b}}

    END

  
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots}

    ${appt_ids}=  Create List
    Set Suite Variable   ${appt_ids}
    FOR   ${b}  IN RANGE   ${count}

        Exit For Loop If    ${b}>=${s1_slots_len}  

        ${apptfor1}=  Create Dictionary  id=${cid${b}}   apptTime=${s1_slots[${b}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${b}}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid${b}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${b}}

    END

    ${resp}=  Get Appointment Status   ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings   ${resp.status_code}  200
    Should Contain  "${resp.json()}"  ${apptStatus[1]}
       ${resp}=  Get Appointment Status   ${apptid0} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Contain  "${resp.json()}"  ${apptStatus[1]}
    
    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}      ${apptid1}         ${apptid0} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    


    ${resp}=  Get Appointment Status   ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}
  
    ${resp}=  Get Appointment Status   ${apptid0} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}
    
   
   


    


JD-TC-change appointment status for multiple appointments- 5

    [Documentation]  single appmt status change arrived  to completed
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
   clear_appt_schedule   ${PUSERNAME85}
     

     ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
 
    ${resp}=  Get Appointment Schedule ById  ${sch_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id1}     batchEnable=${bool[0]}

    
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id1}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
   
    ${resp}=  AddCustomer  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}   ${resp.json()}

    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    Set Suite Variable   ${apptfor}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer   ${cid}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${apptid1}  ${apptid[0]}

  
    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}

    
  
    
      
JD-TC-change appointment status for multiple appointments-6
    [Documentation]   multiple appmt - change status to Completed from confirmed
   
    ${resp}=  Encrypted Provider Login   ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     clear_appt_schedule   ${PUSERNAME85}
      clear_customer   ${PUSERNAME85}

    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id1}  ${resp.json()}

  
    ${fname3}=   FakerLibrary.first_name
    ${lname3}=   FakerLibrary.last_name
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id1}  ${DAY1}  ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id1}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots}

    ${appt_ids}=  Create List
    Set Suite Variable   ${appt_ids}
    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s1_slots_len}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id}  ${sch_id1}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Test Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${a}}

    END


    # ${resp}=  Appointment Action   ${apptStatus[1]}    ${apptid1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Appointment Action   ${apptStatus[1]}    ${apptid2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


      ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Contain  "${resp.json()}"  ${apptStatus[1]}
    
    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Contain  "${resp.json()}"  ${apptStatus[1]}
    
    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}
    
     ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[1]['appointmentStatus']}   ${apptStatus[6]}


JD-TC-change appointment status for multiple appointments- 7

    [Documentation]    multiple account status change started to completed  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
      clear_appt_schedule   ${PUSERNAME85}
      clear_customer   ${PUSERNAME85}

    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}


    ${fname0}=   FakerLibrary.first_name
    ${lname0}=   FakerLibrary.last_name
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

 
    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots}

    ${appt_ids}=  Create List
    Set Test Variable   ${appt_ids}
    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s1_slots_len}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${a}}

    END


   
    ${resp}=  Appointment Action   ${apptStatus[3]}    ${apptid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Appointment Action   ${apptStatus[3]}    ${apptid2}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}

    ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()[1]['appointmentStatus']}   ${apptStatus[3]}
    Should Contain  "${resp.json()}"  ${apptStatus[3]}


    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[2]['appointmentStatus']}   ${apptStatus[6]}

     ${resp}=  Get Appointment Status   ${apptid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()[2]['appointmentStatus']}   ${apptStatus[6]}




JD-TC-change appointment status for multiple appointments UH-2
    [Documentation]  Change appointment status of another provider  (comment : appointment id was number of list ,so it response was 200)
    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401

    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-change appointment status for multiple appointments UH-3
    [Documentation]  Change appointment status without login

    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    ${apptid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-change appointment status for multiple appointments UH-4
    [Documentation]  Change appointment status of invalid appointment  : comment -response 200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME180}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Change multiple Appmt Status     ${apptStatus[6]}    no   tug
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  "${resp.json()}"    "{'no': 'Appointment does not exist', 'tug': 'Appointment does not exist'}"




JD-TC-change appointment status for multiple appointments UH-5

    [Documentation]   check another status work on this URL 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME85}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
     clear_appt_schedule   ${PUSERNAME85}
      clear_customer   ${PUSERNAME85}

    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${fname0}=   FakerLibrary.first_name
    ${lname0}=   FakerLibrary.last_name
    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    ${resp}=  GetCustomer
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${no_of_cust}=  Get Length  ${resp.json()}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  scheduleId=${sch_id}
    ${no_of_slots}=  Get Length  ${resp.json()['availableSlots']}
    @{s1_slots}=  Create List
    FOR   ${i}  IN RANGE   0   ${no_of_slots}
        Run Keyword If  ${resp.json()['availableSlots'][${i}]['noOfAvailbleSlots']} > 0   Append To List   ${s1_slots}  ${resp.json()['availableSlots'][${i}]['time']}
    END
    ${s1_slots_len}=  Get Length  ${s1_slots}

    ${appt_ids}=  Create List
    Set Suite Variable   ${appt_ids}
    FOR   ${a}  IN RANGE   ${count}

        Exit For Loop If    ${a}>=${s1_slots_len}  

        ${apptfor1}=  Create Dictionary  id=${cid${a}}   apptTime=${s1_slots[${a}]}
        ${apptfor}=   Create List  ${apptfor1}
            
        ${cnote}=   FakerLibrary.word
        ${resp}=  Take Appointment For Consumer  ${cid${a}}  ${s_id1}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
            
        ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
        Set Suite Variable  ${apptid${a}}  ${apptid[0]}

        Append To List   ${appt_ids}  ${apptid${a}}

    END


    ${resp}=  Get Appointment Status   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Change multiple Appmt Status    ${apptStatus[3]}    ${apptid1}   ${apptid2}
    Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
    
    Should Be Equal As Strings  "${resp.json()}"   "${INVALID_ACTION}"
    
   