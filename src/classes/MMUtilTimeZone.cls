public class MMUtilTimeZone {

    public static String[] timeZone = new String[] {'-12_a','(GMT-12:00) International Date Line West','-11_a','(GMT-11:00) Midway Island, Samoa','-10_a','(GMT-10:00) Hawaii','-9_a','(GMT-09:00) Alaska','-8_a','(GMT-08:00) Pacific Time (US & Canada)','-8_b','(GMT-08:00) Tijuana, Baja California','-7_a','(GMT-07:00) Mountain Time (US & Canada)','-7_b','(GMT-07:00) Arizona','-7_c','(GMT-07:00) Chihuahua, La Paz, Mazatlan - New','-6_a','(GMT-06:00) Central Time (US & Canada)','-6_b','(GMT-06:00) Saskatchewan','-6_c','(GMT-06:00) Central America','-6_d','(GMT-06:00) Guadalajara, Mexico City, Monterrey - Old','-5_a','(GMT-05:00) Eastern Time (US & Canada)','-5_b','(GMT-05:00) Indiana (East)','-5_c','(GMT-05:00) Bogota, Lima, Quito','-4.5_a','(GMT-04:30) Caracas','-4_a','(GMT-04:00) Atlantic Time (Canada)','-4_b','(GMT-04:00) Georgetown, La Paz, San Juan','-4_c','(GMT-04:00) Manaus','-4_d','(GMT-04:00) Santiago','-3.5_a','(GMT-03:30) Newfoundland','-3_a','(GMT-03:00) Brasilia','-3_b','(GMT-03:00) Buenos Aires','-3_c','(GMT-03:00) Cayenne','-3_d','(GMT-03:00) Greenland','-3_e','(GMT-03:00) Montevideo','-2_a','(GMT-02:00) Mid-Atlantic','-1_a','(GMT-01:00) Cape Verde Is.','-1_b','(GMT-01:00) Azores','0_b','(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London','0_c','(GMT) Casablanca','0_d','(GMT) Monrovia, Reykjavik','1_a','(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb','1_b','(GMT+01:00) Brussels, Copenhagen, Madrid, Paris','1_c','(GMT+01:00) West Central Africa','1_d','(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna','1_e','(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague','2_a','(GMT+02:00) Cairo','2_b','(GMT+02:00) Athens, Bucharest, Istanbul','2_c','(GMT+02:00) Jerusalem','2_d','(GMT+02:00) Amman','2_e','(GMT+02:00) Beirut','2_f','(GMT+02:00) Harare, Pretoria','2_g','(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius','2_h','(GMT+02:00) Minsk','2_i','(GMT+02:00) Windhoek','3_a','(GMT+03:00) Kuwait, Riyadh','3_b','(GMT+03:00) Moscow, St. Petersburg, Volgograd','3_c','(GMT+03:00) Baghdad','3_d','(GMT+03:00) Nairobi','3.5_a','(GMT+03:30) Tehran','4_a','(GMT+04:00) Abu Dhabi, Muscat','4_b','(GMT+04:00) Baku','4_c','(GMT+04:00) Caucasus Standard Time','4_d','(GMT+04:00) Tbilisi','4.5_a','(GMT+04:30) Kabul','5_a','(GMT+05:00) Islamabad, Karachi','5_b','(GMT+05:00) Ekaterinburg','5_c','(GMT+05:00) Tashkent','5.5_a','(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi','5.75_a','(GMT+05:45) Kathmandu','6_a','(GMT+06:00) Novosibirsk', '6_b','(GMT+06:00) Astana, Dhaka','6.5_a','(GMT+06:30) Yangon (Rangoon)','7_a','(GMT+07:00) Bangkok, Hanoi, Jakarta','7_b','(GMT+07:00) Krasnoyarsk','8_a','(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi','8_b','(GMT+08:00) Kuala Lumpur, Singapore','8_c','(GMT+08:00) Taipei','8_d','(GMT+08:00) Perth','8_e','(GMT+08:00) Irkutsk','8_f','(GMT+08:00) Manila','9_a','(GMT+09:00) Seoul','9_b','(GMT+09:00) Osaka, Sapporo, Tokyo','9_c','(GMT+09:00) Yakutsk','9.5_a','(GMT+09:30) Darwin','9.5_b','(GMT+09:30) Adelaide','10_a','(GMT+10:00) Canberra, Melbourne, Sydney','10_b','(GMT+10:00) Brisbane','10_c','(GMT+10:00) Hobart','10_d','(GMT+10:00) Guam, Port Moresby','10_e','(GMT+10:00) Vladivostok','11_a','(GMT+11:00) Magadan, Solomon Is., New Caledonia','12_a','(GMT+12:00) Fiji, Marshall Is.','12_b','(GMT+12:00) Auckland, Wellington','13_c','(GMT+13:00) Nuku alofa'};

    public static DateTime getServerGMTDateTime() {
        return DateTime.now();
    }
    public static DateTime getGMTDateTime(string dtStr, decimal offset) {
        decimal offsetMin = 0;
        DateTime dt = DateTime.valueOfGmt(dtStr);
        dt = dt.addHours(Integer.valueOf(offset));
        offsetMin = offset - Integer.valueOf(offset);
        if (offsetMin != 0) {
            dt = dt.addMinutes(Integer.valueOf(offsetMin * 60));
        }
        return dt;
    }
    public static DateTime getGMTDateTime(DateTime dt, decimal offset) {
        decimal offsetMin = 0;
        dt = dt.addHours(Integer.valueOf(offset));
        offsetMin = offset - Integer.valueOf(offset);
        if (offsetMin != 0) {
            dt = dt.addMinutes(Integer.valueOf(offsetMin * 60));
        }
        return dt;
    }
    public static DateTime getGMTDateTime(DateTime dt, string offset) {
        decimal oset = 0;
        decimal osetMin = 0;
        if (!MMUtils.stringEmptyNull(offset)) {
            if (offset.indexOf('_') >= 0) {
                offset = offset.substring(0,offset.indexOf('_'));
            }
            oset = Decimal.valueOf(offset);
        }
        else {
            oset = 0;
        }
        dt = dt.addHours(Integer.valueOf(oset));
        osetMin = oset - Integer.valueOf(oset);
        if (osetMin != 0) {
            dt = dt.addMinutes(Integer.valueOf(osetMin * 60));
        }
        return dt;
    }
    public static string getCurrentDateTimeTz(DateTime serverDt, string offset, boolean dayLight) {
        DateTime dt = (serverDt != null) ? serverDt : getServerGMTDateTime();
        integer h = 0;
        integer m = 0;
        integer s = 0;
        string hStr = '';
        string mStr = '';
        string sStr = '';
        decimal oset = 0;
        decimal osetMin = 0;
        string am = '';
        if (!MMUtils.stringEmptyNull(offset)) {
            if (offset.indexOf('_') >= 0) {
                offset = offset.substring(0,offset.indexOf('_'));
            }
            oset = Decimal.valueOf(offset);
        }
        else {
            oset = 0;
        }
        oset = oset + (dayLight ? 1 : 0);
        dt = dt.addHours(Integer.valueOf(oset));
        osetMin = oset - Integer.valueOf(oset);
        if (osetMin != 0) {
            dt = dt.addMinutes(Integer.valueOf(osetMin * 60));
        }
        
        h = dt.hourGmt();
        if (h >= 12) { am = ' pm'; } else { am = ' am'; }
        if (h > 12) { h = h - 12; }
        if (h == 0) { hStr = '12'; }
        else if (h < 10 && h > 0) { hStr = '0' + '' + h; } 
        else { hStr = String.valueOf(h); } 
        
        m = dt.minuteGmt();
        if (m < 10) { mStr = '0' + '' + m; } 
        else { mStr = String.valueOf(m); }
        
        s = dt.secondGmt();
        if (s < 10) { sStr = '0' + '' + s; }
        else { sStr = String.valueOf(s); }
        
        return dt.monthGmt() + '/' + dt.dayGmt() + '/' + dt.yearGmt() + ' ' + hStr + ':' + mStr + ':' + sStr + am + ' GMT' +
                getGMTString(oset);
    }
    public static string getGMTString(decimal oset) {
        string gmt = '';
        string sign = '+';
        integer n1 = 0;
        integer n2 = 0;
        string n2Str = '';
        if (oset != 0) {
            if (oset < 0) {
                sign = '-';
                oset = -1 * oset;
            }
            n1 = Integer.valueOf(oset);
            n2 = Integer.valueOf((oset - n1) * 60);
            if (n2 < 10) {
                if (n2 == 0) n2Str = '00';
                else n2Str = '0' + '' + n2;
            }
            else {
                n2Str = String.valueOf(n2);
            }
            if (oset < 10) {
                gmt = sign + '0';
            }
            else {
                gmt = sign;
            }
            gmt += (n1 + '' + n2Str);
        }
        return gmt;
    }
    
    public static DateTime convertToGMT(DateTime dt, string offset, Boolean daylightSaving) {
        decimal oset = 0;
        decimal osetMin = 0;
        if (!MMUtils.stringEmptyNull(offset)) {
            if (offset.indexOf('_') >= 0) {
                offset = offset.substring(0,offset.indexOf('_'));
            }
            oset = Decimal.valueOf(offset) * -1;
        }
        else {
            oset = 0;
        }
        if(daylightSaving) oset -= 1;
        dt = dt.addHours(Integer.valueOf(oset));
        osetMin = oset - Integer.valueOf(oset);
        if (osetMin != 0) {
            dt = dt.addMinutes(Integer.valueOf(osetMin * 60));
        }
        return dt;
    }
}