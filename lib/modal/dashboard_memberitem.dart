class dashboard_memberitem
{
  String id,name,join_date,exp_date,balance,contact,total,paid;
  dashboard_memberitem(this.id, this.name, this.join_date, this.exp_date, this.balance,
      this.contact,this.total,this.paid);


  dashboard_memberitem.fromJson(Map<String,dynamic> json)
  {
    id=json['id'];
    name=json['name'];
    join_date=json['join_date'];
    exp_date=json['exp_date'];
    balance=json['balance'];
    contact=json['contact'];
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
    data['balance']=this.balance;
    data['contact']=this.contact;
    data['total']=this.total;
    data['paid']=this.paid;
  }
}