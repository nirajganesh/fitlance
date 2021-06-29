class commision_item
{
  String id,pt_id,pt_name,paid,pay_date,name;

  commision_item(this.id,
      this.pt_id, this.pt_name, this.paid, this.pay_date,this.name);

  commision_item.fromJson(Map<String,dynamic> json)
  {
    id=json['id'];
    pt_id=json['pt_id'];
    pt_name=json['pt_name'];
    paid=json['paid'];
    pay_date=json['pay_date'];
    name=json['mem_name'];
  }

  Map<String,dynamic> tojson()
  {
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['id']=this.id;
    data['pt_id']=this.pt_id;
    data['pt_name']=this.pt_name;
    data['paid']=this.paid;
    data['pay_date']=this.pay_date;
    data['mem_name']=this.name;
  }
}