class expances_item
{
  String cost,item,date;
  expances_item(this.cost, this.item, this.date);

  expances_item.fromJson(Map<String,dynamic> json)
  {
    cost=json['cost'];
    item=json['item'];
    date=json['date'];
  }

  Map<String,dynamic> tojson()
  {
    final Map<String,dynamic> data=new Map<String,dynamic>();
    data['cost']=this.cost;
    data['item']=this.item;
    data['date']=this.date;
  }

}