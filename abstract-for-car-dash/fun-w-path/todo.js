var moment = require('moment');
var uuid = require('node-uuid');
var AWS = require('aws-sdk');
var db = new AWS.DynamoDB();

function getValue(attribute, type) {
  if (attribute === undefined) {
    return null;
  }
  return attribute[type];
}

function mapTaskItem(item) {
  return {
    "tid": item.tid.N,
    "description": item.description.S,
    "created": item.created.N,
    "due": getValue(item.due, 'N'),
    "category": getValue(item.category, 'S'),
    "completed": getValue(item.completed, 'N')
  };
}

function mapUserItem(item) {
  return {
    "uid": item.uid.S,
    "email": item.email.S,
    "phone": item.phone.S
  };
}

exports.getUsers = function(event, cb) {



  const params = {
    TableName: "users-fun-w-path-dev",
  };

  // fetch all todos from the database
  db.scan(params, (error, result) => {

    //results print
    console.log(JSON.stringify(result))


    // handle potential errors
    if (error) {
      console.error(error);
      cb(new Error('Couldn\'t fetch the todos.'));

    } else {
          var res = {
            "body": result.Items.map(mapUserItem)
          };

          console.log(JSON.stringify(res))

          if (result.LastEvaluatedKey !== undefined) {
            res.headers = {"next": result.LastEvaluatedKey.uid.S};
          }

          cb(null, res);
    }
  })
  //   // create a response
  //   const response = {
  //     statusCode: 200,
  //     body: JSON.stringify(result.Items),
  //   };
  //   callback(null, response);
  // });
  //

};

exports.postUser = function(event, cb) {
//  console.log("postUser", JSON.stringify(event['body']['email']))
    //event = JSON.parse(event)
   const {email, phone}  = JSON.parse(event['body'])
//  console.log(JSON.parse(event['body']).email)
  // console.log(event['body']["email"])
  //   console.log(event["body"]["email"])
  //       console.log(event["body"].email)
  //             console.log(event['body'].email)
  // console.log(JSON.stringify(body))
  //   console.log("body", JSON.stringify(body.phone));
  //     console.log("pjone", JSON.stringify(event));

  var uid = uuid.v4();
  console.log(`the uid is ${uid} and email is phone is ${email} ${phone}`)
  var params = {
    "Item": {
      "uid": {
        "S": uid
      },
      "email": {
        "S": email
      },
      "phone": {
        "S": phone
      }
    },
    "TableName": "users-fun-w-path-dev",
    "ConditionExpression": "attribute_not_exists(uid)"
  };
  db.putItem(params, (err) => {
    if (err) {
      console.log(`what the fuck is goin on ${params}`)
      console.log("errors", JSON.stringify(params));
      cb(err);
    } else {
      cb(null, {"headers": {"uid": uid}, "body": mapUserItem(params.Item)});
    }
  });
};

exports.getUser = function(event, cb) {



    const params = {
      TableName: "users-fun-w-path-dev",
      Key: {
        id: event.pathParameters.userId,
      },
    };

    // fetch user info
    dynamodb.get(params, (error, result) => {
      // handle potential errors
      if (error) {
        console.error(error);
        callback(new Error('Couldn\'t fetch the todo item.'));
        return;
      }else{
            if (data.Item) {
              cb(null, {"body": mapUserItem(result.Item)});
            } else {
              cb(new Error('not found'));
            }
        }
      // // create a response
      // const response = {
      //   statusCode: 200,
      //   body: JSON.stringify(result.Item),
      // };
      // callback(null, response);
    });


  // console.log("getUser", JSON.stringify(event));
  //
  // console.log(JSON.parse(event))
  //
  // const {parameters} = JSON.parse(event)
  // var params = {
  //   "Key": {
  //     "uid": {
  //       "S": parameters.userId
  //     }
  //   },
  //   "TableName": "users-fun-w-path-dev"
  // };
  // db.getItem(params, function(err, data) {
  //   if (err) {
  //     cb(err);
  //   } else {
  //     if (data.Item) {
  //       cb(null, {"body": mapUserItem(data.Item)});
  //     } else {
  //       cb(new Error('not found'));
  //     }
  //   }
  // });hh
};

exports.deleteUser = function(event, cb) {
  console.log("deleteUser", JSON.stringify(event));

  console.log(JSON.parse(event))

  const {parameters} = JSON.parse(event)


  var params = {
    "Key": {
      "uid": {
        "S": parameters.userId
      }
    },
    "TableName": "users-fun-w-path-dev"
  };
  db.deleteItem(params, function(err) {
    if (err) {
      cb(err);
    } else {
      cb();
    }
  });
};

exports.postTask = function(event, cb) {
  console.log("postTask", JSON.stringify(event));


  var tid = Date.now();



  const {pathParameters} = event

  var body = {}

  try {

    body = JSON.parse(event['body'])

  }
  catch(error) {
    body = {description:"this didnt work on the task"}
    console.log(`there is an error parsing the event`)
  }

  console.log(`the path is${pathParameters.userId}`)



  var params = {
    "Item": {
      "uid": {
        "S": pathParameters.userId
      },
      "tid": {
        "N": tid.toString()
      },
      "description": {
        "S": body.description
      },
      "created": {
        "N": moment().format("YYYYMMDD")
      }
    },
    "TableName": "tasks-fun-w-path-dev",
    "ConditionExpression": "attribute_not_exists(uid) and attribute_not_exists(tid)"
  };
  if (body.dueat) {
    params.Item.due = {
      "N": body.dueat
    };
  }
  if (body.category) {
    params.Item.category = {
      "S": body.category
    };
  }

  console.log(`params is ${params.Item}`)
  db.putItem(params, (err) => {
    if (err) {
      cb(err);
    } else {
      cb(null, {"headers": {"uid": pathParameters.userId, "tid": tid}, "body": mapTaskItem(params.Item)});
    }
  });
};

exports.getTasks = function(event, cb) {
  console.log("getTasks", JSON.stringify(event));


  const {pathParameters} = event
  let parameters = pathParameters


  var params = {
    "KeyConditionExpression": "uid = :uid",
    "ExpressionAttributeValues": {
      ":uid": {
        "S": parameters.userId
      }
    },
    "TableName": "tasks-fun-w-path-dev",
    "Limit": parameters.limit || 10
  };
  if (parameters.next) {
    params.KeyConditionExpression += ' AND tid > :next';
    params.ExpressionAttributeValues[':next'] = {
      "N": parameters.next
    };
  }
  if (parameters.overdue) {
    params.FilterExpression = "due < :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.due) {
    params.FilterExpression = "due = :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.withoutdue) {
    params.FilterExpression = "attribute_not_exists(due)";
  } else if (parameters.futuredue) {
    params.FilterExpression = "due > :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.dueafter) {
    params.FilterExpression = "due > :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": parameters.dueafter};
  } else if (parameters.duebefore) {
    params.FilterExpression = "due < :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": parameters.duebefore};
  }
  if (parameters.category) {
    if (params.FilterExpression === undefined) {
      params.FilterExpression = '';
    } else {
      params.FilterExpression += ' AND ';
    }
    params.FilterExpression += 'category = :category';
    params.ExpressionAttributeValues[':category'] = {
      "S": parameters.category
    };
  }
  db.query(params, (err, data) => {
    if (err) {
      cb(err);
    } else {
      var res = {
        "body": data.Items.map(mapTaskItem)
      };
      if (data.LastEvaluatedKey !== undefined) {
        res.headers = {"next": data.LastEvaluatedKey.tid.N};
      }
      cb(null, res);
    }
  });
};

exports.deleteTask = function(event, cb) {
  console.log("deleteTask", JSON.stringify(event));
  console.log(JSON.parse(event))

  const {parameters} = JSON.parse(event)



  var params = {
    "Key": {
      "uid": {
        "S": parameters.userId
      },
      "tid": {
        "N": parameters.taskId
      }
    },
    "TableName": "tasks-fun-w-path-dev"
  };
  db.deleteItem(params, function(err) {
    if (err) {
      cb(err);
    } else {
      cb();
    }
  });
};

exports.putTask = function(event, cb) {
  console.log("putTask", JSON.stringify(event));

  console.log(JSON.parse(event))

  const {parameters} = JSON.parse(event)

  var params = {
    "Key": {
      "uid": {
        "S": parameters.userId
      },
      "tid": {
        "N": parameters.taskId
      }
    },
    "UpdateExpression": "SET completed = :yyyymmdd",
    "ExpressionAttributeValues": {
      ":yyyymmdd": {
        "N": moment().format("YYYYMMDD")
      }
    },
    "TableName": "tasks-fun-w-path-dev"
  };
  db.updateItem(params, function(err) {
    if (err) {
      cb(err);
    } else {
      cb();
    }
  });
};

exports.getTasksByCategory = function(event, cb) {
  console.log("getTasksByCategory", JSON.stringify(event));
  console.log(JSON.parse(event))

  const {parameters} = JSON.parse(event)


  var params = {
    "KeyConditionExpression": "category = :category",
    "ExpressionAttributeValues": {
      ":category": {
        "S": parameters.category
      }
    },
    "TableName": "tasks-fun-w-path-dev",
    "IndexName": "category-index",
    "Limit": parameters.limit || 10
  };
  if (parameters.next) {
    params.KeyConditionExpression += ' AND tid > :next';
    params.ExpressionAttributeValues[':next'] = {
      "N": parameters.next
    };
  }
  if (parameters.overdue) {
    params.FilterExpression = "due < :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.due) {
    params.FilterExpression = "due = :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.withoutdue) {
    params.FilterExpression = "attribute_not_exists(due)";
  } else if (parameters.futuredue) {
    params.FilterExpression = "due > :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": moment().format("YYYYMMDD")};
  } else if (parameters.dueafter) {
    params.FilterExpression = "due > :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": parameters.dueafter};
  } else if (parameters.duebefore) {
    params.FilterExpression = "due < :yyyymmdd";
    params.ExpressionAttributeValues[':yyyymmdd'] = {"N": parameters.duebefore};
  }
  db.query(params, function(err, data) {
    if (err) {
      cb(err);
    } else {
      var res = {
        "body": data.Items.map(mapTaskItem)
      };
      if (data.LastEvaluatedKey !== undefined) {
        res.headers = {"next": data.LastEvaluatedKey.tid.N};
      }
      cb(null, res);
    }
  });
};
