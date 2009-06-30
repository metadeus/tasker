local models = require "luv.db.models"
local fields = require "luv.fields"
local references = require "luv.fields.references"
local widgets = require "luv.fields.widgets"
local auth = require "luv.contrib.auth"
local tostring = tostring
local string = require "luv.string"
local table = require "luv.table"

module(...)

local Task = models.Model:extend{
	__tag = .....".Task";
	Meta = {labels={"task";"tasks"}};
	_ajaxUrl = "/ajax/task/set";
	newStatuses = {"";"новое";"новая";"новый"};
	doneStatuses = {"сделано";"готово";"завершено";"закончено";"выполнено";"выполнена"};
	title = fields.Text{required=true;label="Название"};
	description = fields.Text{maxLength=false;label="Описание"}:addClasses{"huge";"resizable"};
	dateCreated = fields.Datetime{autoNow=true};
	createdBy = references.ManyToOne{references=auth.models.User;required=true;choices=auth.models.User:all()}:setAjaxWidget(widgets.Select());
	assignedTo = references.ManyToOne{references=auth.models.User;label="Исполнитель";choices=auth.models.User:all()}:setAjaxWidget(widgets.Select());
	dateToBeDone = fields.Date{label="Срок (дата)";regional="ru"};
	timeToBeDone = fields.Time{label="Срок (время)"};
	important = fields.Boolean{label="приоритетная задача";defaultValue=false};
	status = fields.Text{label="Текущее состояние";defaultValue="новая"}:addClass "tiny";
	isNew = function (self)
		if not self.status or table.ifind(self.newStatuses, string.utf8lower(self.status)) then
			return true
		end
		return false
	end;
	isDone = function (self)
		if self.status and table.ifind(self.doneStatuses, string.utf8lower(self.status)) then
			return true
		end
		return false
	end;
	__tostring = function (self) return tostring(self.title) end;
}

local Log = models.Model:extend{
	__tag = .....".Log";
	Meta = {labels={"log";"logs"}};
	user = references.ManyToOne{references=auth.models.User;required=true};
	action = fields.Text{required=true};
	text = fields.Text{required=true};
	dateTime = fields.Datetime{autoNow=true};
	logTaskCreate = function (self, task, user)
		self:create{user=user;action="create";text="<a href="..string.format("%q", "/task/"..task.pk)..">"..tostring(task).."</a>"}
	end;
	logTaskEdit = function (self, task, user, field, value)
		self:create{user=user;action="edit";text="<a href="..string.format("%q", "/task/"..task.pk)..">"..tostring(task).."</a>"}
	end;
	logTaskDelete = function (self, task, user)
		self:create{user=user;action="delete";text=tostring(task)}
	end;
}

return {Task=Task;Log=Log}
