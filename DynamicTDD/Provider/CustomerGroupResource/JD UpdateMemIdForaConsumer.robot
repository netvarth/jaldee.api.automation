*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Groups
Library           String
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${self}                   0

***Test Cases***

JD-TC-UpdateMemId-1

    [Documentation]    update   member id for a consumer  with new member id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5
    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END
    ${mem}=  FakerLibrary.Random Int  min=10  max=99
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName}   ${cust ids[1]}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem}

    ${mem1}=  FakerLibrary.Random Int  min=100  max=999
 
    ${resp}=   Update Member Id for a consumer in a group    ${groupName}   ${cust ids[1]}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}


JD-TC-UpdateMemId-2

    [Documentation]    update  member id with  different member id for different consumers in two different  consumer groups  
   
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${groupName2}=   FakerLibrary.word
    ${desc2}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName2}  ${desc2}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
  
   
    ${resp}=  Add Customers to Group   ${groupName2}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}

    ${resp}=  Add Customers to Group   ${groupName2}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem2}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName2}   ${cid2}    ${mem2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem2}
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}
   
    ${mem}=  FakerLibrary.Random Int  min=10  max=99
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}   ${cid}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem}


    ${mem12}=  FakerLibrary.Random Int  min=100  max=999
    ${resp}=   Update Member Id for a consumer in a group    ${groupName2}   ${cid2}    ${mem12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem12}


JD-TC-UpdateMemId-3

    [Documentation]   update member id with  same member id for same consumer  in two different  consumer group 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${groupName2}=   FakerLibrary.word
    ${desc2}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName2}  ${desc2}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}

    ${resp}=  Add Customers to Group   ${groupName2}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
        
    ${resp}=    Add MemberId for a consumer in group    ${groupName2}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}
  
    ${mem12}=  FakerLibrary.Random Int  min=10  max=99
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}   ${cid}    ${mem12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem12}

  
    ${resp}=   Update Member Id for a consumer in a group    ${groupName2}   ${cid}    ${mem12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem12}



JD-TC-UpdateMemId-UH1

    [Documentation]  without login
    
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
    ${groupName1}=   FakerLibrary.word
  
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateMemId-UH2

    [Documentation]  consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
    ${groupName1}=   FakerLibrary.word
  
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"




JD-TC-UpdateMemId-UH3

    [Documentation]   update member id with another group name
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem1}=  FakerLibrary.word
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem12}=  FakerLibrary.Random Int  min=100  max=999
 
    ${resp}=   Update Member Id for a consumer in a group    nsshv   ${cid}    ${mem12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${GROUP_NOT_EXIST}"


 
    

JD-TC-UpdateMemId-UH4

    [Documentation]  update member id for a customer, that customer doesn't exit customer group  
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}
    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid5}  ${resp.json()}


    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
   
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${000}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mem12}=  FakerLibrary.Random Int  min=100  max=999

    ${resp}=   Update Member Id for a consumer in a group    nsshv   ${cid}    ${mem12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${GROUP_NOT_EXIST}"


 

JD-TC-UpdateMemId-UH5

    [Documentation]  another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}
   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    12ws
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

  
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}  ${cid}    12ws
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${GROUP_NOT_EXIST}"

JD-TC-UpdateMemId-UH6

    [Documentation]  update member id with same member id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

 
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}

    
 
    ${resp}=   Update Member Id for a consumer in a group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${THE_MEMBERID_ALREADY_USED}"

   
JD-TC-UpdateMemId-UH7

    [Documentation]  update member id for two consumer with same member id in same group
    ${resp}=  Encrypted Provider Login  ${PUSERNAME24}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME24}
    clear_customer   ${PUSERNAME24}

    ${groupName3}=   FakerLibrary.word
    ${desc3}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName3}  ${desc3}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid3}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid3}   groupName=${groupName3}  
    ...   status=${grpstatus[0]}  description=${desc3}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName3}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid3}   groupName=${groupName3}  
    ...   status=${grpstatus[0]}  description=${desc3}  consumerCount=5

    ${mem3}=  FakerLibrary.Random Int  min=10  max=99
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName3}   ${cust ids[1]}    ${mem3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName3}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem3}
    
    ${mem31}=  FakerLibrary.Random Int  min=10  max=99
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName3}   ${cust ids[2]}    ${mem31}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName3}   ${cust ids[2]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem31}
   
    ${mem}=  FakerLibrary.Random Int  min=100  max=999
    ${resp}=   Update Member Id for a consumer in a group    ${groupName3}   ${cust ids[1]}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName3}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem}

    ${resp}=   Update Member Id for a consumer in a group    ${groupName3}   ${cust ids[2]}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${THE_MEMBERID_ALREADY_USED}"

    
JD-TC-UpdateMemId-4
     [Documentation]  update member id by user
   
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550257
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    ${id}=  get_id  ${MUSERNAME_E}
    ${lid}=  Create Sample Location
    Set Suite Variable  ${lid}
    
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}
    
    ${resp}=   Get Location ById  ${lid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    
    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}
    
    ${resp}=   Get Location ById  ${lid3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    


    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366458
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346245
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[1]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_customer_groups  ${PUSERNAME_U1}
    clear_customer   ${PUSERNAME_U1}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5
    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END
    ${mem}=  FakerLibrary.Random Int  min=10  max=99
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName}   ${cust ids[1]}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem}

    ${mem1}=  FakerLibrary.Random Int  min=100  max=999
 
    ${resp}=   Update Member Id for a consumer in a group    ${groupName}   ${cust ids[1]}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}


JD-TC-UpdateMemId-5

    [Documentation]  create member id by user update member id by branch

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

      ${resp}=  AddCustomer  ${CUSERNAME9}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid9}  ${resp.json()}
        
    

    ${resp}=  Add Customers to Group   ${groupName}   ${cid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${mem}=  FakerLibrary.Random Int  min=10  max=99
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName}   ${cid9}    ${mem}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName}   ${cid9} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem}
   
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 

    ${mem1}=  FakerLibrary.Random Int  min=100  max=999
 
    ${resp}=   Update Member Id for a consumer in a group    ${groupName}    ${cid9}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Member Id of a consumer in a group    ${groupName}    ${cid9} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}
   
   