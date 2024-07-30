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
JD-TC-AddCustomertoGroup-1
    [Documentation]  Add provider customers to a group

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
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


JD-TC-AddCustomertoGroup-2
    [Documentation]  Add provider customers to multiple groups
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   10

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Run Keyword If  ${a} > ${4}  Append To List   ${list2}  ${cid${a}}
        ...  ELSE   Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${resp}=  Add Customers to Group   ${groupName1}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    ${customers1}=  get_customers_from_group  ${groupid1}
    Log  ${customers1}

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

    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len1}  5

    ${i}=  Set Variable  ${5}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END


JD-TC-AddCustomertoGroup-3
    [Documentation]  Create group of jaldee consumers added as provider customers through bookings 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}
    
    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}
    clear_location   ${PUSERNAME88}
    clear_service    ${PUSERNAME88}

    ${SERVICE1}=    FakerLibrary.Word
    ${s_id}=  Create Sample Service  ${SERVICE1}
    ${lid}=  Create Sample Location 
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    clear_queue   ${PUSERNAME88}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Sample Queue  ${lid}   ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}  ${resp.json()}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    FOR   ${a}  IN RANGE   10

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${cnote}=   FakerLibrary.word
        ${resp}=  Add To Waitlist Consumers  ${pid}  ${q_id}  ${DAY1}  ${s_id}  ${cnote}  ${bool[0]}  ${self}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200 
        
        ${wid}=  Get Dictionary Values  ${resp.json()}
        Set Test Variable  ${wid${a}}  ${wid[0]}

        ${resp}=  Get consumer Waitlist By Id   ${wid${a}}  ${pid}   
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}   waitlistedBy=${waitlistedby[0]}
        

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    END

    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   10
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        Run Keyword If  ${a} > ${4}  Append To List   ${list2}  ${cid${a}}
        ...  ELSE   Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${resp}=  Add Customers to Group   ${groupName1}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=5

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

    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len1}  5

    ${i}=  Set Variable  ${5}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END
    
    

JD-TC-AddCustomertoGroup-4
    [Documentation]  Create group of non jaldee provider customers

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   10

        ${PO_Number}    Generate random string    4    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${fname}=  FakerLibrary.first_name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH${a}}  firstName=${fname}  lastName=${lname}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Run Keyword If  ${a} > ${4}  Append To List   ${list2}  ${cid${a}}
        ...  ELSE   Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${resp}=  Add Customers to Group   ${groupName1}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=5

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5
    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERPH${i}}

        ${i}=  Evaluate  ${i}+1

    END

    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len1}  5
    ${i}=  Set Variable  ${5}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERPH${1}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${1}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERPH${i}}

        ${i}=  Evaluate  ${i}+1

    END


JD-TC-AddCustomertoGroup-5
    [Documentation]  Add customers to group, update the group name and add more customers.  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}  

    ${groupName1}=   FakerLibrary.word
    ${resp}=  Update Customer Group   ${groupid}  ${groupName1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    FOR   ${a}  IN RANGE   5  10

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${list2}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName1}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=10

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  10

    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END


JD-TC-AddCustomertoGroup-6
    [Documentation]  Add customers to group, remove these customers and add them again. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
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

    ${resp}=  Remove Multiple Customer from Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  0

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

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


JD-TC-AddCustomertoGroup-7
    [Documentation]  Add same customers to 2 different groups.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

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

    ${resp}=  Add Customers to Group   ${groupName1}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=5

    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len1}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len1}  5

    ${i}=  Set Variable  ${0}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END


JD-TC-AddCustomertoGroup-8
    [Documentation]  update name of 2nd group with old name of 1st group and add customers using old 1st group name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${groupName1}=   FakerLibrary.word
    ${desc1}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName1}  ${desc1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid1}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   10

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Run Keyword If  ${a} > ${4}  Append To List   ${list2}  ${cid${a}}
        ...  ELSE   Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

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

    ${groupName_new}=   FakerLibrary.word
    ${resp}=  Update Customer Group   ${groupid}  ${groupName_new}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName_new}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${resp}=  Update Customer Group   ${groupid1}  ${groupName}  ${desc1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=0

    ${resp}=  Add Customers to Group   ${groupName}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid1}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc1}  consumerCount=5

    ${resp}=  GetCustomer  groups-eq=${groupid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5

    ${i}=  Set Variable  ${5}
    FOR   ${a}  IN RANGE   ${len-1}  0  -1
        
        ${resp1}=  GetCustomer  phoneNo-eq=${CUSERNAME${i}}
        Log   ${resp1.json()}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Should Be Equal As Strings  ${resp1.json()[0]['id']}  ${cid${i}}

        Verify Response List  ${resp}   ${a}    id=${cid${i}}   phoneNo=${CUSERNAME${i}}

        ${i}=  Evaluate  ${i}+1

    END


JD-TC-AddCustomertoGroup-UH1
    [Documentation]  Add the same customers to same group again. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
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

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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


JD-TC-AddCustomertoGroup-UH2
    [Documentation]  Add customers to group without login. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
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

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-AddCustomertoGroup-UH3
    [Documentation]  Add customers to group by consumer login. 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Customer Groups 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${groupName}  ${resp.json()[0]['groupName']}

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5        
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        Append To List   ${cust ids}  ${cid${a}}

    END

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-AddCustomertoGroup-UH4
    [Documentation]  Add customers to group without creating a group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    # clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word

    ${cust ids}=  Create List

    FOR   ${a}  IN RANGE   5        
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()[0]['id']}

        Append To List   ${cust ids}  ${cid${a}}

    END
    
    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"


# JD-TC-AddCustomertoGroup-UH5
#     [Documentation]  Add customers to group without groupname.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     clear_customer_groups  ${PUSERNAME88}
#     clear_customer   ${PUSERNAME88}

#     ${cust ids}=  Create List

#     FOR   ${a}  IN RANGE   5

#         ${resp}=  AddCustomer  ${CUSERNAME${a}}
#         Log  ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Set Test Variable  ${cid${a}}  ${resp.json()}
        
#         ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
#         Log   ${resp.json()}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

#         Append To List   ${cust ids}  ${cid${a}}

#     END

#     ${resp}=  Add Customers to Group   ${EMPTY}  @{cust ids}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"


JD-TC-AddCustomertoGroup-UH6
    [Documentation]  Add customers to group without customers.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  Add Customers to Group   ${groupName}  @{EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROVIDER_ID_LIST_IS_EMPTY}"


JD-TC-AddCustomertoGroup-UH7
    [Documentation]  Add customers to group when group is disabled.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
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

    ${resp}=  Disable Customer Group   ${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[1]}  description=${desc}  consumerCount=0

    ${resp}=  Add Customers to Group   ${groupName}  @{cust ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  0


JD-TC-AddCustomertoGroup-UH8
    [Documentation]  Add customers to group with old group name after updating group name.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${list1}=  Create List
    ${list2}=  Create List

    FOR   ${a}  IN RANGE   5

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${list1}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}  

    ${groupName1}=   FakerLibrary.word
    ${resp}=  Update Customer Group   ${groupid}  ${groupName1}  ${desc}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName1}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=5

    ${customers}=  get_customers_from_group  ${groupid}
    Log  ${customers}

    FOR   ${a}  IN RANGE   5  10

        ${resp}=  AddCustomer  ${CUSERNAME${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}
        
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${list2}  ${cid${a}}

    END

    ${resp}=  Add Customers to Group   ${groupName}  @{list2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"

    ${resp}=  GetCustomer  groups-eq=${groupid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    Should Be Equal As Strings  ${len}  5


JD-TC-AddCustomertoGroup-UH9
    [Documentation]  Add customers to group of another provider.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME86}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME86}
    clear_customer   ${PUSERNAME86}

    ${groupName}=   FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${resp}=  Create Customer Group   ${groupName}  ${desc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${groupid}  ${resp.json()}

    ${resp}=  Get Customer Group by id  ${groupid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${groupid}   groupName=${groupName}  
    ...   status=${grpstatus[0]}  description=${desc}  consumerCount=0

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME88}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_customer_groups  ${PUSERNAME88}
    clear_customer   ${PUSERNAME88}

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
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${GROUP_NOT_EXIST}"

