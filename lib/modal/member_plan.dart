class member_plan
{
  String plan_name,join_date,exp_date,rate,disc,paid,bal,payment_date;

  member_plan(this.plan_name, this.join_date, this.exp_date, this.rate,
      this.disc, this.paid, this.bal, this.payment_date);

  member_plan.fromJson(Map<String,dynamic> json)
  {
    plan_name=json['plan_name'];
    join_date=json['join_date'];
    exp_date=json['exp_date'];
    rate=json['rate'];
    disc=json['disc'];
    paid=json['paid'];
    bal=json['bal'];
    payment_date=json['payment_date'];
  }

  Map<String,dynamic> tojson()
  {
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['plan_name']=this.plan_name;
    data['join_date']=this.join_date;
    data['exp_date']=this.exp_date;
    data['rate']=this.rate;
    data['disc']=this.disc;
    data['paid']=this.paid;
    data['bal']=this.bal;
    data['payment_date']=this.payment_date;
  }
}