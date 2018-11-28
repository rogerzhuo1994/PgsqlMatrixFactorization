from pg import DB
import json
db = DB(dbname='ricedb_comp533', host='127.0.0.1', port=5432, user='postgres', passwd='123456')


f = open('yelp_academic_dataset_review.json')
line = f.readline()
i = 0
while line:
    json_object = json.loads(line)
    user_id = json_object['user_id']
    review_id = json_object['review_id']
    business_id = json_object['business_id']
    stars = json_object['stars']
    date = json_object['date']
    text = json_object['text']
    useful = json_object['useful']
    funny = json_object['funny']
    cool = json_object['cool']
    
    db.insert('review', user_id = user_id, review_id = review_id, business_id = business_id, stars = stars, 
              date = date, text = text, useful = useful, funny = funny, cool = cool)
    
    i = i + 1
    if (i % 10000) == 0:
        print(str(int(i / 10000) * 10000) + ' lines processed...')
    
    line = f.readline()
    
f.close()
print('finished processing...')    



f = open('yelp_academic_dataset_tip.json')
line = f.readline()
i = 0
while line:
    json_object = json.loads(line)
    user_id = json_object['user_id']
    business_id = json_object['business_id']
    date = json_object['date']
    text = json_object['text']
    likes = json_object['likes']
    
    db.insert('tip', user_id = user_id, business_id = business_id,
              date = date, text = text, likes = likes)
    
    i = i + 1
    if (i % 10000) == 0:
        print(str(int(i / 10000) * 10000) + ' lines processed...')
    
    line = f.readline()
    
f.close()
print('finished processing...')




f = open('yelp_academic_dataset_user.json')
line = f.readline()
i = 0
while line:
    json_object = json.loads(line)
    
    user_id = json_object['user_id']
    name = json_object['name']
    review_count = json_object['review_count']
    yelping_since = json_object['yelping_since']
    friends = json_object['friends']
    useful = json_object['useful']
    funny = json_object['funny']
    cool = json_object['cool']
    fans = json_object['fans']
    elite = json_object['elite']
    average_stars = json_object['average_stars']
    compliment_hot = json_object['compliment_hot']
    compliment_profile = json_object['compliment_profile']
    compliment_more = json_object['compliment_more']
    compliment_cute = json_object['compliment_cute']
    compliment_list = json_object['compliment_list']
    compliment_note = json_object['compliment_note']
    compliment_plain = json_object['compliment_plain']
    compliment_cool = json_object['compliment_cool']
    compliment_funny = json_object['compliment_funny']
    compliment_writer = json_object['compliment_writer']
    compliment_photos = json_object['compliment_photos']
    db.insert('yelp_user', user_id = user_id, name = name, review_count = review_count, yelping_since = yelping_since, friends = friends,
             useful = useful, funny = funny, cool = cool, fans = fans, elite = elite, average_stars = average_stars,
             compliment_hot = compliment_hot, compliment_profile = compliment_profile, compliment_more = compliment_more,
             compliment_cute = compliment_cute, compliment_list = compliment_list, compliment_note = compliment_note, 
             compliment_plain = compliment_plain, compliment_cool = compliment_cool, compliment_funny = compliment_funny,
             compliment_writer = compliment_writer, compliment_photos = compliment_photos)
    
    i = i + 1
    if (i % 10000) == 0:
        print(str(int(i / 10000) * 10000) + ' lines processed...')
    
    line = f.readline()
    
f.close()
print('finished processing...')




f = open('yelp_academic_dataset_business.json')
line = f.readline()
i = 0
while line:
    json_object = json.loads(line)
    business_id = json_object['business_id']
    name = json_object['name']
    neighborhood = json_object['neighborhood']
    address = json_object['address']
    city = json_object['city']
    state = json_object['state']
    postal_code = json_object['postal_code']
    latitude = json_object['latitude']
    longitude = json_object['longitude']
    stars = json_object['stars']
    review_count = json_object['review_count']
    is_open = json_object['is_open']
    attributes = json.dumps(json_object['attributes'])
    categories = json_object['categories']
    hours = json.dumps(json_object['hours'])
    
#     print('hours: ' + hours)
#     print('attributes: ' + attributes)
#     try:
    db.insert('business', business_id = business_id, name = name, state = state, postal_code = postal_code, 
              neighborhood = neighborhood, address = address, city = city, latitude = latitude, longitude = longitude,
             stars = stars, review_count = review_count, is_open = is_open, attributes = attributes, categories = categories,
             hours = hours)
#     except:
#         print(name)
#         print(address)
#         print(city)
#         print(neighborhood)
#         print('---------------')
    
    i = i + 1
    if (i % 10000) == 0:
        print(str(int(i / 10000) * 10000) + ' lines processed...')
    
    line = f.readline()
    
f.close()
print('finished processing...')







f = open('yelp_academic_dataset_checkin.json')
line = f.readline()
i = 0
while line:
    json_object = json.loads(line)
    time = json.dumps(json_object['time'])
    business_id = json_object['business_id']
    
    db.insert('checkins', time = time, business_id = business_id)
    
    i = i + 1
    if (i % 10000) == 0:
        print(str(int(i / 10000) * 10000) + ' lines processed...')
    
    line = f.readline()
    
f.close()
print('finished processing...')    