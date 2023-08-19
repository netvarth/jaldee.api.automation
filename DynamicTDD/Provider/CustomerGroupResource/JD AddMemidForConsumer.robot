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

JD-TC-AddMemberidForConsumer-1
    [Documentation]  Add member id for a consumer
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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
     # ${memId}=  Convert To String  ${mem}
    #    ${PO_Number}    Generate random string    7    0123456789
    #     ${cons_num}    Convert To Integer  ${PO_Number}
    
    # ${memId}=    Generate random string    4    0123456789
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

JD-TC-AddMemberidForConsumer-2
    [Documentation]  Add different member id for same consumer, two different  consumer group

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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
   
    ${mem2}=  FakerLibrary.Random Int  min=1  max=9
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName2}   ${cid}    ${mem2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem2}
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}


JD-TC-AddMemberidForConsumer-3

    [Documentation]  Add different  member id for different consumer, same  consumer group

     ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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
    
    ${mem31}=  FakerLibrary.Random Int  min=1  max=9
    
    ${resp}=    Add MemberId for a consumer in group    ${groupName3}   ${cust ids[2]}    ${mem31}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName3}   ${cust ids[2]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem31}

    ${resp}=   Get Member Id of a consumer in a group    ${groupName3}   ${cust ids[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem3}

JD-TC-AddMemberidForConsumer-4

    [Documentation]  Add  different member id for different consumer in two different  consumer groups
   
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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

    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid2}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
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
   
    ${mem2}=  FakerLibrary.Random Int  min=1  max=9
      
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



JD-TC-AddMemberidForConsumer-5
    [Documentation]  Add  same member id for same consumer ,two different  consumer group
   
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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


JD-TC-AddMemberidForConsumer-6

    [Documentation]  Add same member id for  different  consumer , two different   consumer group
   
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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
   
    # ${mem2}=  FakerLibrary.Random Int  min=1  max=9
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName2}   ${cid2}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName2}   ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}
    
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}



JD-TC-AddMemberidForConsumer-UH1
    [Documentation]  Add same  member id for different consumer in  same   consumer group
    
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    # ${groupName2}=   FakerLibrary.word
    # ${desc2}=   FakerLibrary.sentence
    # ${resp}=  Create Customer Group   ${groupName2}  ${desc2}     generateGrpMemId=${bool[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${groupid2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

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
   
  
   
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
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

    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # ${mem2}=  FakerLibrary.Random Int  min=1  max=9
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid2}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"    "${THE_MEMBERID_ALREADY_USED}"


JD-TC-AddMemberidForConsumer-UH2
    [Documentation]  without login
    
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
    ${groupName1}=   FakerLibrary.word
  
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419 
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-AddMemberidForConsumer-Uh3
    [Documentation]  consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
    ${groupName1}=   FakerLibrary.word
  
    ${groupName_new}=   FakerLibrary.word
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"     "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-AddMemberidForConsumer-UH4
    [Documentation]  ADD memberid , create  group with generateGrpMemId is false

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    # ${groupName2}=   FakerLibrary.word
    # ${desc2}=   FakerLibrary.sentence
    # ${resp}=  Create Customer Group   ${groupName2}  ${desc2}     generateGrpMemId=${bool[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${groupid2}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  Add Customers to Group   ${groupName1}   ${cid3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid3}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${MEMBERID_ALREADY_DISABLED}"

JD-TC-AddMemberidForConsumer-UH5
    [Documentation]  add memberid  for a consumer , the consumer does not contain any  customer group
    
  
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

   
    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid4}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
      
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid4}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${THIS_MEMBER_NOT_ADDED_THIS_GROUP}"

JD-TC-AddMemberidForConsumer-7

    [Documentation]   member id was a word
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

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

    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${mem1}


 
    
JD-TC-AddMemberidForConsumer-UH6

    [Documentation]  add memberid  for a consumer , to another cutomer group
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_customer_groups  ${PUSERNAME64}
    clear_customer   ${PUSERNAME64}

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}
    ${groupName2}=   FakerLibrary.word
  
    ${resp}=  Create Customer Group   ${groupName2}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid2}  ${resp.json()}

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   3

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

    ${resp}=  Add Customers to Group   ${groupName1}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
  
    ${mem1}=  FakerLibrary.Random Int  min=10  max=99
       
    ${resp}=    Add MemberId for a consumer in group    ${groupName2}   ${cust ids[1]}    ${mem1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${THIS_MEMBER_NOT_ADDED_THIS_GROUP}"

JD-TC-AddMemberidForConsumer-8

    [Documentation]   member id is zero
    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}     generateGrpMemId=${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    ${resp}=  Add Customers to Group   ${groupName1}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
   
    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    ${000}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Member Id of a consumer in a group    ${groupName1}   ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}   ${000}


 

JD-TC-AddMemberidForConsumer-UH7

    [Documentation]  another provider login

    ${resp}=  Provider Login  ${PUSERNAME64}  ${PASSWORD}
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

  
    ${resp}=  Provider Login  ${PUSERNAME55}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Add MemberId for a consumer in group    ${groupName1}   ${cid}    12ws
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"     "${GROUP_NOT_EXIST}"

   
