*** Settings ***
Suite Teardown    Delete All Sessions
#Test Teardown     Run Keywords  Delete All Sessions  AND  Remove File  cookies.txt
Force Tags        Search
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}	   CONSULTATION1
${SERVICE2}	   CONSULTATION2 
${queue1}   Morning queue
${queue2}   Evening queue

*** Test Cases ***

JD-TC-CloudSearch-1
    [Documentation]   search data after creating business profile
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comments ***
    clear_service    ${PUSERNAME5}
    clear_location   ${PUSERNAME5}
    clear_queue   ${PUSERNAME5}
    Set Suite Variable    ${pname}    ${resp.json()['userName']}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3 
    Set Suite Variable  ${list}
    ${bs1}=  FakerLibrary.bs
    Set Suite Variable   ${bs1}
    ${ph1}=  Evaluate  ${PUSERNAME}+0070073010
    Set Suite Variable   ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME}+0070073011
    Set Suite Variable   ${ph2}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${ph_nos1}=  Phone Numbers  ${name1}  Phoneno  ${ph1}  all
    Set Suite Variable  ${ph_nos1}  ${ph_nos1}
    ${ph_nos2}=  Phone Numbers  ${name2}  Phoneno  ${ph2}  all
    Set Suite Variable  ${ph_nos2}  ${ph_nos2}
    ${emails1}=  Emails  ${name3}  Email   ${P_Email}${bs1}.${test_mail}  all
    Set Suite Variable  ${emails1}  ${emails1}    
    ${bs_name}=  FakerLibrary.bs
    Set Suite Variable   ${bs_name}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${latti}=  get_latitude
    Set Suite Variable   ${latti}
    ${longi}=  get_longitude
    Set Suite Variable   ${longi}
    ${companySuffix}=  FakerLibrary.companySuffix
    Set Suite Variable   ${companySuffix}   
    ${postcode}=  FakerLibrary.postcode
    Set Suite Variable   ${postcode}
    ${address}=  get_address
    Set Suite Variable   ${address}
    ${sTime}=  add_time  0   5
    Set Suite Variable   ${sTime}   
    ${eTime}=  add_time  5  5
    Set Suite Variable   ${eTime}
    ${description}=     FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${resp}=  Create Business Profile   ${bs_name}  ${description}   ${name1}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  1 minutes
    ${resp}=  Disable Search Data
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Search Data
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${pid}=  get_acc_id  ${PUSERNAME5}
    Set Suite Variable  ${pid}  ${pid}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid1}  ${resp.json()[0]['id']}
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=${bs_name}    short_name=${name1}   location1=${latti},${longi}  place1=${city}  address1=${address}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  ${pname}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

*** Comments ***
JD-TC-CloudSearch-2
    [Documentation]   search data after updating business profile
    ${resp}=  Encrypted Provider Login   ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  
    Set Suite Variable    ${pname}     ${resp.json()['userName']}
    ${name1}=  FakerLibrary.name
    Set Suite Variable   ${name1}
    ${name2}=  FakerLibrary.name
    Set Suite Variable   ${name2}
    ${name3}=  FakerLibrary.name
    Set Suite Variable   ${name3}
    ${ph1}=  Evaluate  ${PUSERNAME}+0070073010
    Set Suite Variable   ${ph1}
    ${ph2}=  Evaluate  ${PUSERNAME}+0070073011
    Set Suite Variable   ${ph2}
    ${ph_nos1}=  Phone Numbers  ${name1}  Phoneno  ${ph1}  self
    Set Suite Variable  ${ph_nos1}  ${ph_nos1}
    ${ph_nos2}=  Phone Numbers  ${name2}  Phoneno  ${ph2}  all
    Set Suite Variable  ${ph_nos2}  ${ph_nos2}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs1}.${test_mail}  all
    Set Suite Variable  ${emails1}  ${emails1}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    ${bName}=  FakerLibrary.name
    Set Suite Variable   ${bName}
    ${city}=   get_place
    Set Suite Variable   ${city}
    ${shname}=  FakerLibrary.name
    Set Suite Variable   ${shname}
    ${resp}=  Update Business Profile without details  ${bName}  ${city}  ${shname}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=${bName}   short_name=${shname}  location1=${latti},${longi}  place1=${city}  address1=${address}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  ${pname}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-3
    [Documentation]   search data after updating Basic info
    ${resp}=  Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id}=  get_id  ${PUSERNAME4} 
    Log  ${resp.json()}
    ${firstName}=  FakerLibrary.name
    Set Suite Variable   ${firstName}
    ${lastName}=  FakerLibrary.name
    Set Suite Variable   ${lastName}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ['Male', 'Female', 'Others']
    ${resp}=  Update Service Provider  ${id}  ${firstName}  ${lastName}  ${gender}  ${dob}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=${bName}   short_name=${shname}  location1=${latti},${longi}  place1=${city}  address1=${address}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
*** Comments ***
JD-TC-CloudSearch-4
    [Documentation]   search data after creating location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
	${list}=  Create List  1  2  5  6
    ${city}=  get_place
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime1}=  add_time  0  5
    ${eTime1}=  add_time  0  15
    ${latti1}=  get_latitude
    ${longi1}=  get_longitude
    ${resp}=  Create Location  ${city}  ${longi1}  ${latti1}  www.${companySuffix}.com  ${postcode}  ${address}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid2}  ${resp.json()}
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi    location1=${latti1},${longi1}  place1=Eranakulam  address1=Palliyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-5
    [Documentation]   search data after updating location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${city}=  get_place
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${resp}=  Update Location  ${lid2}
    Log  ${resp.json()}
    ${resp}=  Update Location  ${city}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}  ${address}  free  True  ${lid2} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday
    
JD-TC-CloudSearch-6
    [Documentation]   search data after disabling location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Location  ${lid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['found']}  0
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-7
    [Documentation]   search data after enabling location
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME8}
    ${resp}=  Enable Location  ${lid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-8
    [Documentation]   search data after creating queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List  1  2  3  4  5  6  7
    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}
    ${notifytype}    Random Element     ['none','pushMsg','email']
    Set Suite Variable   ${notifytype}
    ${notify}    Random Element     ['True','False']
    Set Suite Variable   ${notify}
    ${isPrePayment}    Random Element     ['True','False'] 
    Set Suite Variable   ${isPrePayment}
    ${taxable}    Random Element     ['True','False'] 
    clear_service  ${PUSERNAME9}
    ${resp}=  Create Service  ${SERVICE1}  ${description}   30    ACTIVE  Waitlist  ${notify}   ${notifytype}  45  500  ${isPrePayment}  ${taxable}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    Set Suite Variable  ${s_id}  ${resp.json()} 
    ${resp}=  Create Service  ${SERVICE2}  ${description}   30  ACTIVE  Waitlist  ${notify}   ${notifytype}  45  500  ${isPrePayment}  ${taxable}
    Should Be Equal As Strings  ${resp.status_code}  200     
    Set Suite Variable  ${s_id1}  ${resp.json()} 
    ${sTime2}=  add_time
    ${eTime2}=  add_time
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid2}  ${s_id}  ${s_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][5]}  Wednesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][6]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday
    
JD-TC-CloudSearch-9
    [Documentation]   search data after rating waitlist
    ${resp}=  ProviderLogin   ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME1}
    Log   ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${wid}   3  good
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=   Waitlist Rating  ${wid}   4  good
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  rating=3.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][5]}  Wednesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][6]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response CloudSearch  ${resp}  rating=3.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-10
    [Documentation]   search data after rating updation
    ${resp}=  ProviderLogin  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Update Rating  ${wid[0]}   2  bad
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][5]}  Wednesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][6]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-11
    [Documentation]   search data after disabling queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Queue  ${qid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-12
    [Documentation]   search data after enabling queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Enable Queue  ${qid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][5]}  Wednesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][6]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-13
    [Documentation]   search data after updating queue
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List  5  6  7
    ${resp}=  Update Queue  ${qid}  ${queue2}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  2  3  ${lid2}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi   location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-14
    [Documentation]   search data after adding adword
    ${resp}=  Encrypted Provider Login   ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Adword  latest 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Add Adword  latest1 
    Should Be Equal As Strings  ${resp.status_code}   200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][1]}  latest1
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi   location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][1]}  latest1
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-15
    [Documentation]   search data after removing adword
    ${resp}=  Encrypted Provider Login  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Adword
    Should Be Equal As Strings  ${resp.status_code}   200 
    Set Test Variable  ${adId}  ${resp.json()[0]['id']}   
    ${resp}=  Delete Adword  ${adId}
    Should Be Equal As Strings  ${resp.status_code}   200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Verify Response CloudSearch  ${resp}  title=Devi Health Care   short_name=Devi   location1=${latti},${longi}  place1=Kochi  address1=Challiyil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Verify Response CloudSearch  ${resp}  rating=2.5  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday


JD-TC-CloudSearch-16
    [Documentation]   search data after updating domain virtual fields 
    ${resp}=  ProviderLogin  ${PUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Domain Level Field For healthCare   Clinic1  fever  headache  Surgery  Angiography  8years  Albany Medical Center Prize  2012  March  Dr.Ravi  www.anjalihealthcare.com
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${pid1}=  get_acc_id  ${PUSERNAME17}
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p1lid1}  ${resp.json()[0]['id']}
    ${resp}=  Cloud Search  q=_id:'${pid1}-${p1lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.text}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['medicalproblems_cust'][0]}  fever
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['medicalprocedures_cust'][0]}  Angiography
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['associatedclinics_cust'][0]}  Clinic1
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['symptoms_cust'][0]}  headache
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['treatments_cust'][0]}  Surgery
    Verify Response CloudSearch  ${resp}  sector=healthCare  sub_sector=physiciansSurgeons

JD-TC-CloudSearch-17
    [Documentation]   search data after updating subdomain virtual fields 
    ${resp}=  ProviderLogin   ${PUSERNAME18}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Subdomain Field For healthCare  physiciansSurgeons  2017  January  MBBS  JUBILEE    
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.text}
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['doceducationalqualification_cust'][0]}  [{"qualificationName":"MBBS","qualifiedyear":"2017","qualifiedMonth":"January","qualifiedFrom":"JUBILEE"}]
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Verify Response CloudSearch  ${resp}  sector=foodJoints  title=Devi Health Care   short_name=Devi   location1=${latti},${longi}  place1=Kochi  address1=Challiyil House  sub_sector=physiciansSurgeons
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Verify Response CloudSearch  ${resp}  rating=2.5  sector=foodJoints  sub_sector=restaurants  title=Devi Health Care   short_name=Devi  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  asha km
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-18
    [Documentation]   search data after updating logo
    # ${resp}=  pyproviderlogin  ${PUSERNAME19}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    # @{resp}=  uploadLogoImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${uid}=  get_uid   ${PUSERNAME19}
    Set Suite Variable  ${uid}
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  logo=http://ynwtest.youneverwait.com/${uid}/logo/mylogo.jpg

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  logo=http://ynwtest.youneverwait.com/${uid}/logo/mylogo.jpg

JD-TC-CloudSearch-19
    [Documentation]   search data after updating gallery
    # ${resp}=  pyproviderlogin  ${PUSERNAME20}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200   
    # @{resp}=  uploadGalleryImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search   q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${gal}  ${resp.json()['hits']['hit'][0]['fields']['gallery_thumb_nails']}
    Should Contain Match  ${gal}  http://ynwtest.youneverwait.com/${uid}/gallery/thumbnail*
    ${len}=  Get Length  ${resp.json()['hits']['hit'][0]['fields']['gallery_thumb_nails']}
    Should Be Equal As Integers  ${len}  1

    ${resp}=  Cloud Search   q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${gal}  ${resp.json()['hits']['hit'][0]['fields']['gallery_thumb_nails']}
    Should Contain Match  ${gal}  http://ynwtest.youneverwait.com/${uid}/gallery/thumbnail*
    ${len}=  Get Length  ${resp.json()['hits']['hit'][0]['fields']['gallery_thumb_nails']}
    Should Be Equal As Integers  ${len}  1

JD-TC-CloudSearch-20
    [Documentation]   search data after updating Basic info and business profile 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME21}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${id}=  get_id  ${PUSERNAME22}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname} 
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname} 
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${gender}   Random Element    ['Male','Femail','Others']
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${lid}  ${resp.json()[0]['id']}
    ${bName}=  FakerLibrary.name
    Set Suite Variable   ${bName}
    ${shname}=  FakerLibrary.name
    Set Suite Variable   ${shname}
    ${city}=  get_place
    ${ph_nos1}=  Evaluate  ${PUSERNAME}+0070073010
    Set Suite Variable   ${ph_nos1}
    ${ph_nos2}=  Evaluate  ${PUSERNAME}+0070073011
    Set Suite Variable   ${ph_nos2}
    ${emails1}=  Emails  ${name3}  Email   ${P_Email}${bs1}.${test_mail}  all
    Set Suite Variable  ${emails1}  ${emails1}
    ${resp}=  Update Business Profile without details  ${bName}  ${city}  ${shname}  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Arun Health Care   short_name=Arun  rating=2.5  sector=healthCare  location1=${latti},${longi}  place1=Kochi  address1=Challiyil House  sub_sector=physiciansSurgeons
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  manu m
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Thursday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Friday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][3]}  Sunday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][4]}  Saturday

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response CloudSearch  ${resp}  title=Arun Health Care   short_name=Arun  rating=2.5  sector=foodJoints  sub_sector=restaurants  location1=${latti},${longi}  place1=Thrissur  address1=Puliparambil House 
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['provider']}  manu m
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['adwords'][0]}  latest1
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][0]}  Monday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][1]}  Tuesday
    Should Be Equal As Strings  ${resp.json()['hits']['hit'][0]['fields']['days'][2]}  Sunday

JD-TC-CloudSearch-21
    [Documentation]   disable search data 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable Search Data
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2 sec
    ${resp}=  Cloud Search  q=_id:'${pid}-${lid1}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['found']}  0

    ${resp}=  Cloud Search  q=_id:'${pid}-${lid2}'  q.parser=structured
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hits']['found']}  0