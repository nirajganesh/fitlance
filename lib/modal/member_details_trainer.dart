class member_details_trainer
{
  String name,id,plan_name,plan_time,join_date,exp_date,total,paid;

  member_details_trainer(this.name, this.id, this.plan_name, this.plan_time,
      this.join_date, this.exp_date, this.total, this.paid);


  member_details_trainer.fromJson(Map<String,dynamic> json)
  {
    id=json['id'];
    name=json['name'];
    join_date=json['join_date'];
    exp_date=json['exp_date'];
    plan_time=json['plan_time'];
    total=json['total'];
    paid=json['paid'];
  }

  Map<String,dynamic> tojson()
  {
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['id']=this.id;
    data['name']=this.name;
    data['join_date']=this.join_date;
    data['exp_date']=this.exp_date;
    data['plan_time']=this.plan_time;
    data['paid']=this.paid;
  }
}