local models = require"luv.db.models"
local fields = require"luv.fields"
local references = require"luv.fields.references"
local widgets = require"luv.fields.widgets"
local auth = require"luv.contrib.auth"
local tostring = tostring
local string = require"luv.string"
local table = require"luv.table"

module(...)

local property = models.Model.property

local Task = models.Model:extend{
	__tag = .....".Task";
	__tostring = function (self) return tostring(self.title) end;
	_ajaxUrl = "/ajax/task/field-set.json";
	_newStatuses = {"";"new";"новое";"новая";"новый"};
	newStatuses = property"table";
	_doneStatuses = {"done";"finished";"completed";"сделано";"сделан";"сделана";"готово";"готова";"готов";"завершено";"закончено";"закончена";"закончен";"выполнено";"выполнена"};
	doneStatuses = property"table";
	Meta = {labels={"task";"tasks"}};
	title = fields.Text{true; "title"; classes={"big"}};
	description = fields.Text{max=false; "description"}:addClasses{"huge"};
	dateCreated = fields.Datetime{autoNow=true};
	createdBy = references.ManyToOne{auth.models.User; true; choices=auth.models.User:all()}:ajaxWidget(widgets.Select());
	assignedTo = references.ManyToOne{auth.models.User; "executor"; choices=auth.models.User:all()}:ajaxWidget(widgets.Select());
	dateToBeDone = fields.Date"term (date)";
	timeToBeDone = fields.Time"term (time)";
	important = fields.Boolean{"priority task"; default = false};
	status = fields.Text{"current state"; default = ("new"):tr()}:addClass"tiny";
	isNew = function (self)
		if not self.status or table.ifind(self:newStatuses(), self.status:lower()) then
			return true
		end
		return false
	end;
	isDone = function (self)
		if self.status and table.ifind(self:doneStatuses(), self.status:lower()) then
			return true
		end
		return false
	end;
}

local Log = models.Model:extend{
	__tag = .....".Log";
	Meta = {labels={"log";"logs"}};
	user = references.ManyToOne{references=auth.models.User;required=true};
	action = fields.Text{required=true};
	text = fields.Text{required=true};
	dateTime = fields.Datetime{autoNow=true};
	logTaskCreate = function (self, task, user)
		self:create{user=user;action="create";text='<a href=%(href)s>%(task)s</a>' % {href=("%q"):format("/task/"..task.pk);task=tostring(task)}}
	end;
	logTaskEdit = function (self, task, user, field, value)
		self:create{user=user;action="edit";text='<a href=%(href)s>%(task)s</a>' % {href=("%q"):format("/task/"..task.pk);task=tostring(task)}}
	end;
	logTaskDelete = function (self, task, user)
		self:create{user=user;action="delete";text=tostring(task)}
	end;
}

local Options = models.Model:extend{
	__tag = .....".Options";
	Meta = {labels={"options";"options"}};
	user = references.OneToOne{auth.models.User; true};
	tasksPerPage = fields.Int{"tasks per page"; default=10; true; choices={{10;10};{20;20};{30;30};{40;40};{50;50}}};
	notifFreq = fields.Int{"frequency of notifications"; default=24*60*60; true; choices={{0;("never"):tr()};{60*60;("once an hour"):tr()};{24*60*60;("once a day"):tr()};{7*24*60*60;("once a week"):tr()}}};
	lang = fields.Text{"language"; true; default="ru"; choices={{"en";"English"};{"ru";"Русский"}}};
}

local Notification = models.Model:extend{
	__tag = .....".Notification";
	Meta = {labels={"notification";"notifications"}};
	to = references.ManyToOne{auth.models.User; true};
	dateCreated = fields.Datetime{autoNow=true};
	dateSended = fields.Datetime();
	text = fields.Text{max=false; true};
}

return {Task=Task;Log=Log;Options=Options;admin={Task;Log};Notification=Notification}
